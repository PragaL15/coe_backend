package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type FacultyRequest struct {
	FacultyID          int    `json:"faculty_id"`
	// TotalAllocatedPapers int  `json:"total_allocated_papers"`
	PapersLeft         int    `json:"papers_left"`
	CourseID           int    `json:"course_id"`
	Remarks            string `json:"remarks"`
	ApprovalStatus     int    `json:"approval_status"`
	Status             int    `json:"status"`
	DeadlineLeft       int    `json:"deadline_left"`
	SemCode            string `json:"sem_code"`
	SemAcademicYear    string `json:"sem_academic_year"`
	// Year               int    `json:"year"`
}

func PostFacultyRequestHandler(c *fiber.Ctx) error {
	var request FacultyRequest

	// Parse the request body into the FacultyRequest struct.
	if err := c.BodyParser(&request); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate the required fields.
	if err := validateFacultyRequest(request); err != nil {
		log.Printf("Validation error: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Check if faculty_id exists in faculty_table
	var exists bool
	err := config.DB.QueryRow(
		context.Background(),
		"SELECT EXISTS(SELECT 1 FROM faculty_table WHERE faculty_id = $1)",
		request.FacultyID,
	).Scan(&exists)

	if err != nil || !exists {
		log.Printf("Faculty ID %d does not exist", request.FacultyID)
		return c.Status(http.StatusNotFound).JSON(fiber.Map{
			"error": "Faculty ID does not exist",
		})
	}

	// Fetch the faculty name from faculty_table using faculty_id.
	var facultyName string
	err = config.DB.QueryRow(
		context.Background(),
		"SELECT faculty_name FROM faculty_table WHERE faculty_id = $1",
		request.FacultyID,
	).Scan(&facultyName)

	if err != nil {
		log.Printf("Failed to fetch faculty name for faculty_id %d: %v", request.FacultyID, err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch faculty name",
		})
	}

	// Define the SQL query for inserting data into the faculty_request table.
	query := `
    INSERT INTO faculty_request (
        faculty_id, papers_left, course_id, 
        remarks, approval_status, status, deadline_left, sem_code, 
        sem_academic_year
    ) 
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
`

	// Execute the database query with the provided parameters.
	_, err = config.DB.Exec(
		context.Background(),
		query,
		request.FacultyID,
		// request.TotalAllocatedPapers,
		request.PapersLeft,
		request.CourseID,
		request.Remarks,
		request.ApprovalStatus,
		request.Status,
		request.DeadlineLeft,
		request.SemCode,
		request.SemAcademicYear,
		// request.Year,
	)
	if err != nil {
		log.Printf("Error inserting faculty request: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert faculty request into the database",
		})
	}

	// Respond with a success message.
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Faculty request created successfully",
	})
}

func validateFacultyRequest(req FacultyRequest) error {
	if req.FacultyID <= 0 {
		return fiber.NewError(http.StatusBadRequest, "FacultyID must be a positive integer")
	}
	// if req.TotalAllocatedPapers <= 0 {
	// 	return fiber.NewError(http.StatusBadRequest, "TotalAllocatedPapers must be a positive integer")
	// }
	if req.CourseID <= 0 {
		return fiber.NewError(http.StatusBadRequest, "CourseID must be a positive integer")
	}
	if req.SemCode == "" {
		return fiber.NewError(http.StatusBadRequest, "SemCode cannot be empty")
	}
	if req.SemAcademicYear == "" {
		return fiber.NewError(http.StatusBadRequest, "SemAcademicYear cannot be empty")
	}
	// if req.Year <= 0 {
	// 	return fiber.NewError(http.StatusBadRequest, "Year must be a positive integer")
	// }
	return nil
}

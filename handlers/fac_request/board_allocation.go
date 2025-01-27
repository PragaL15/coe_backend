package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type FacultyBoardRequest struct {
	FacultyID      int    `json:"faculty_id"`
	PaperAllocated int    `json:"paper_allocated"`
	CourseID       int    `json:"course_id"`
	DeptID         int    `json:"dept_id"`
	Deadline       int    `json:"deadline"`
	Status         int    `json:"status"`
	BCEID          string `json:"bce_id"`
	SemCode        string `json:"sem_code"`
}

func PostFacultyBoardRequestHandler(c *fiber.Ctx) error {
	var request FacultyBoardRequest

	if err := c.BodyParser(&request); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body. Please check the data format.",
		})
	}

	if err := validateFacultyBoardRequest(request); err != nil {
		log.Printf("Validation error: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	var exists bool
	err := config.DB.QueryRow(
		context.Background(),
		"SELECT EXISTS(SELECT 1 FROM faculty_table WHERE faculty_id = $1)",
		request.FacultyID,
	).Scan(&exists)

	if err != nil {
		log.Printf("Error checking faculty ID %d existence: %v", request.FacultyID, err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Internal server error while verifying faculty ID",
		})
	}

	if !exists {
		log.Printf("Faculty ID %d does not exist", request.FacultyID)
		return c.Status(http.StatusNotFound).JSON(fiber.Map{
			"error": "Faculty ID does not exist",
		})
	}

	// Insert data into the faculty_all_records table.
	query := `
    INSERT INTO faculty_all_records (
        faculty_id, paper_allocated, course_id, dept_id, deadline, status, bce_id,sem_code
    ) 
    VALUES ($1, $2, $3, $4, $5, $6, $7,$8)
`
	_, err = config.DB.Exec(
		context.Background(),
		query,
		request.FacultyID,
		request.PaperAllocated,
		request.CourseID,
		request.DeptID,
		request.Deadline,
		request.Status,
		request.BCEID,
		request.SemCode,
	)

	if err != nil {
		log.Printf("Error inserting into faculty_all_records: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert faculty record into the database",
		})
	}

	// Respond with a success message.
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Faculty record created successfully",
	})
}

func validateFacultyBoardRequest(req FacultyBoardRequest) error {
	if req.FacultyID <= 0 {
		return fiber.NewError(http.StatusBadRequest, "Faculty ID must be a positive integer")
	}
	if req.PaperAllocated < 0 {
		return fiber.NewError(http.StatusBadRequest, "Paper allocated must be a non-negative integer")
	}
	if req.CourseID < 0 {
		return fiber.NewError(http.StatusBadRequest, "Course ID must be a positive integer")
	}
	if req.DeptID < 0 {
		return fiber.NewError(http.StatusBadRequest, "Department ID must be a positive integer")
	}
	if req.Deadline < 0 {
		return fiber.NewError(http.StatusBadRequest, "Deadline must be a non-negative integer")
	}
	if req.BCEID == "" {
		return fiber.NewError(http.StatusBadRequest, "BCE ID cannot be empty")
	}
	return nil
}

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
}

func PostFacultyBoardRequestHandler(c *fiber.Ctx) error {
	var request FacultyBoardRequest

	// Parse the request body into the FacultyBoardRequest struct.
	if err := c.BodyParser(&request); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate the required fields.
	if err := validateFacultyBoardRequest(request); err != nil {
		log.Printf("Validation error: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Check if faculty_id exists in the faculty_table.
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

	// Insert data into the faculty_all_records table.
	query := `
    INSERT INTO faculty_all_records (
        faculty_id, paper_allocated, course_id, dept_id, deadline, status, bce_id
    ) 
    VALUES ($1, $2, $3, $4, $5, $6, $7)
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
		return fiber.NewError(http.StatusBadRequest, "FacultyID must be a positive integer")
	}
	if req.PaperAllocated < 0 {
		return fiber.NewError(http.StatusBadRequest, "PaperAllocated must be a non-negative integer")
	}
	if req.CourseID <= 0 {
		return fiber.NewError(http.StatusBadRequest, "CourseID must be a positive integer")
	}
	if req.Deadline < 0 {
		return fiber.NewError(http.StatusBadRequest, "Deadline must be a non-negative integer")
	}
	if req.BCEID == "" {
		return fiber.NewError(http.StatusBadRequest, "BCEID cannot be empty")
	}
	return nil
}

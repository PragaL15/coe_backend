package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type FacultyDailyUpdateRequest struct {
	FacultyID          int    `json:"faculty_id"`
	PaperID            string `json:"paper_id"`
	PaperCorrectedToday int   `json:"paper_corrected_today"`
	Remarks            string `json:"remarks"`
}

func PostFacultyDailyUpdateHandler(c *fiber.Ctx) error {
	var request FacultyDailyUpdateRequest

	// Parse the request body into the FacultyDailyUpdateRequest struct.
	if err := c.BodyParser(&request); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate the request.
	if err := validateFacultyDailyUpdateRequest(request); err != nil {
		log.Printf("Validation error: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Check if the faculty_id and paper_id exist in faculty_all_records table.
	var exists bool
	err := config.DB.QueryRow(
		context.Background(),
		"SELECT EXISTS(SELECT 1 FROM faculty_all_records WHERE faculty_id = $1 AND paper_id = $2)",
		request.FacultyID,
		request.PaperID,
	).Scan(&exists)

	if err != nil || !exists {
		log.Printf("Faculty ID %d and Paper ID %s do not exist", request.FacultyID, request.PaperID)
		return c.Status(http.StatusNotFound).JSON(fiber.Map{
			"error": "Faculty ID or Paper ID does not exist",
		})
	}

	// Define the SQL query for inserting data into daily_faculty_updates table.
	query := `
    INSERT INTO daily_faculty_updates (
        faculty_id, paper_id, paper_corrected_today, remarks
    ) 
    VALUES ($1, $2, $3, $4)
`

	// Execute the query to insert the daily update into the database.
	_, err = config.DB.Exec(
		context.Background(),
		query,
		request.FacultyID,
		request.PaperID,
		request.PaperCorrectedToday,
		request.Remarks,
	)
	if err != nil {
		log.Printf("Error inserting daily faculty update: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert daily faculty update into the database",
		})
	}

	// Return a success response.
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Faculty daily update created successfully",
	})
}

func validateFacultyDailyUpdateRequest(req FacultyDailyUpdateRequest) error {
	if req.FacultyID <= 0 {
		return fiber.NewError(http.StatusBadRequest, "FacultyID must be a positive integer")
	}
	if req.PaperID == "" {
		return fiber.NewError(http.StatusBadRequest, "PaperID cannot be empty")
	}
	if req.PaperCorrectedToday < 0 {
		return fiber.NewError(http.StatusBadRequest, "PaperCorrectedToday must be greater than or equal to 0")
	}
	return nil
}

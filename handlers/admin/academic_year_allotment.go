package Adminhandlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type AcademicYear struct {
	ID              int       `json:"id"`
	AcademicYear    string    `json:"academic_year"`
	Status          int       `json:"status,omitempty"`
}

func PostAcademicYearHandler(c *fiber.Ctx) error {
	var academicYear AcademicYear

	// Parse the request body into the AcademicYear struct
	if err := c.BodyParser(&academicYear); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate the required fields
	if academicYear.AcademicYear == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'academic_year' is required",
		})
	}

	if academicYear.Status == 0 {
		academicYear.Status = 1
	}


	// SQL Query to insert the new academic year record
	query := `
	INSERT INTO academic_year_table (academic_year, status)
	VALUES ($1, $2)
	RETURNING id;
`

	// Insert the academic year record into the database and capture the generated id
	var insertedID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		academicYear.AcademicYear,
		academicYear.Status,
	).Scan(&insertedID)

	// Handle errors if the insertion fails
	if err != nil {
		log.Printf("Error inserting academic year record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert academic year record into the database",
		})
	}

	// Return success response with the inserted id
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Academic year record created successfully",
		"id":      insertedID,
	})
}

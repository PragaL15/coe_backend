package Adminhandlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type Semester struct {
	ID               int    `json:"id"`
	SemCode          string `json:"sem_code"`
	SemAcademicYear  string `json:"sem_academic_year"`
	Year             int    `json:"year"`
	Status           int    `json:"status,omitempty"`
	CreatedAt        time.Time `json:"createdat,omitempty"`
	UpdatedAt        time.Time `json:"updatedat,omitempty"`
}

func PostSemesterHandler(c *fiber.Ctx) error {
	var semester Semester

	// Parse the request body into the semester struct
	if err := c.BodyParser(&semester); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate the required fields
	if semester.SemCode == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'sem_code' is required",
		})
	}
	if semester.SemAcademicYear == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'sem_academic_year' is required",
		})
	}
	if semester.Year == 0 {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'year' is required",
		})
	}

	// Default status to 1 if it's not provided
	if semester.Status == 0 {
		semester.Status = 1
	}

	// Set the timestamps for createdat and updatedat
	now := time.Now()
	if semester.CreatedAt.IsZero() {
		semester.CreatedAt = now
	}
	if semester.UpdatedAt.IsZero() {
		semester.UpdatedAt = now
	}

	// SQL Query to insert the new semester record
	query := `
	INSERT INTO semester_table (sem_code, sem_academic_year, year, status, createdat, updatedat)
	VALUES ($1, $2, $3, $4, $5, $6)
	RETURNING id;
`


	// Insert the semester record into the database and capture the generated id
	var insertedID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		semester.SemCode,
		semester.SemAcademicYear,
		semester.Year,
		semester.Status,
		semester.CreatedAt,
		semester.UpdatedAt,
	).Scan(&insertedID)

	// Handle errors if the insertion fails
	if err != nil {
		log.Printf("Error inserting semester record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert semester record into the database",
		})
	}

	// Return success response with the inserted id
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Semester record created successfully",
		"id":      insertedID,
	})
}

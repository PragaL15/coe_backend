package Adminhandlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/PragaL15/coe_backend/config"
	"github.com/gofiber/fiber/v2"
)

type Semester struct {
	ID              int       `json:"id"`
	SemCode         string    `json:"sem_code"`
	SemAcademicYear string    `json:"sem_academic_year"`
	Status          int       `json:"status,omitempty"`
	CreatedAt       time.Time `json:"createdat,omitempty"`
	UpdatedAt       time.Time `json:"updatedat,omitempty"`
}
func PostSemesterHandler(c *fiber.Ctx) error {
	var semester Semester
	if err := c.BodyParser(&semester); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}
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

	if semester.Status == 0 {
		semester.Status = 1
	}

	query := `
	INSERT INTO semester_table (sem_code, sem_academic_year, status, createdat, updatedat)
	VALUES ($1, $2, $3, $4, $5)
	RETURNING id, createdat, updatedat;
	`

	now := time.Now()
	var insertedID int
	var createdAt, updatedAt time.Time

	err := config.DB.QueryRow(
		context.Background(),
		query,
		semester.SemCode,
		semester.SemAcademicYear,
		semester.Status,
		now,
		now,
	).Scan(&insertedID, &createdAt, &updatedAt)
	if err != nil {
		log.Printf("Error inserting semester record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert semester record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Semester record created successfully",
		"id":      insertedID,
		"createdat": createdAt,
		"updatedat": updatedAt,
	})
}

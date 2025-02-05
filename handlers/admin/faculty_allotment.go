package Adminhandlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type Faculty struct {
	FacultyID   int    `json:"faculty_id,omitempty"` // Don't include faculty_id in the input (it will be generated automatically)
	FacultyName string `json:"faculty_name"`
	Dept        int    `json:"dept"`
	Status      int    `json:"status,omitempty"`
	MobileNum   string `json:"mobile_num"`
	Email       string `json:"email"`
}

func PostFacultyHandler(c *fiber.Ctx) error {
	var faculty Faculty
	if err := c.BodyParser(&faculty); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if faculty.FacultyName == "" || faculty.Dept <= 0 || faculty.MobileNum == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input data. 'faculty_name', 'dept', and 'mobile_num' are required.",
		})
	}

	if len(faculty.MobileNum) > 15 {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Mobile number exceeds the maximum length of 15 characters.",
		})
	}

	if faculty.Status == 0 {
		faculty.Status = 1
	}

	query := `
		INSERT INTO faculty_table (faculty_name, dept, status, createdat, updatedat, mobile_num, email)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING faculty_id
	`
	now := time.Now()
	var insertedFacultyID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		faculty.FacultyName,
		faculty.Dept,
		faculty.Status,
		now,
		now,
		faculty.MobileNum,
		faculty.Email,
	).Scan(&insertedFacultyID)

	if err != nil {
		log.Printf("Error inserting faculty record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert faculty record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message":    "Faculty record created successfully",
		"faculty_id": insertedFacultyID,
	})
}

package Adminhandlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type Course struct {
	CourseCode string `json:"course_code"` // Required field
	CourseName string `json:"course_name"` // Required field
	Status     int    `json:"status,omitempty"`
	SemCode    string `json:"sem_code"` // Required field
}

func PostCourseHandler(c *fiber.Ctx) error {
	var course Course

	// Parse request body into the `Course` struct
	if err := c.BodyParser(&course); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Input validation
	if course.CourseCode == "" || course.CourseName == "" || course.SemCode == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'course_code', 'course_name', and 'sem_code' are required fields.",
		})
	}

	// Set default status if not provided
	if course.Status == 0 {
		course.Status = 1
	}

	// Check if the `sem_code` exists in `semester_table`
	var exists bool
	err := config.DB.QueryRow(
		context.Background(),
		"SELECT EXISTS(SELECT 1 FROM semester_table WHERE sem_code=$1)",
		course.SemCode,
	).Scan(&exists)
	if err != nil {
		log.Printf("Error checking 'sem_code' existence: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to validate 'sem_code'. Please try again.",
		})
	}

	if !exists {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid 'sem_code'. Please provide a valid semester code.",
		})
	}

	// Prepare the SQL query for inserting the course
	query := `
		INSERT INTO course_table (course_code, course_name, status, sem_code, createdat, updatedat)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	now := time.Now()

	// Execute the query
	_, err = config.DB.Exec(
		context.Background(),
		query,
		course.CourseCode,  // course_code
		course.CourseName,  // course_name
		course.Status,      // status
		course.SemCode,     // sem_code
		now,                // createdat
		now,                // updatedat
	)
	if err != nil {
		log.Printf("Error inserting course record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert course record into the database",
		})
	}

	// Respond with success
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Course record created successfully",
	})
}

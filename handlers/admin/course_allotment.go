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
	CourseID   int    `json:"course_id"`
	CourseCode string `json:"course_code"`
	CourseName string `json:"course_name"`
	Status     int    `json:"status,omitempty"`
}

func PostCourseHandler(c *fiber.Ctx) error {
	var course Course
	if err := c.BodyParser(&course); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if course.CourseID <= 0 || course.CourseCode == "" || course.CourseName == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input data. 'course_id', 'course_code', and 'course_name' are required.",
		})
	}

	if course.Status == 0 {
		course.Status = 1
	}

	query := `
		INSERT INTO course_table (course_id, course_code, course_name, status, createdat, updatedat)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`

	now := time.Now()

	var insertedID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		course.CourseID,
		course.CourseCode,
		course.CourseName,
		course.Status,
		now,
		now,
	).Scan(&insertedID)

	if err != nil {
		log.Printf("Error inserting course record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert course record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Course record created successfully",
		"id":      insertedID,
	})
}

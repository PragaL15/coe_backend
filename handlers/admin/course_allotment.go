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
	CourseCode string `json:"course_code"` 
	CourseName string `json:"course_name"` 
	Status     int    `json:"status,omitempty"`
	SemCode    string `json:"sem_code"` 
}

func PostCourseHandler(c *fiber.Ctx) error {
	var course Course

	if err := c.BodyParser(&course); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if course.CourseCode == "" || course.CourseName == "" || course.SemCode == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'course_code', 'course_name', and 'sem_code' are required fields.",
		})
	}

	if course.Status == 0 {
		course.Status = 1
	}

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

	query := `
		INSERT INTO course_table (course_code, course_name, status, sem_code, createdat, updatedat)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	now := time.Now()

	_, err = config.DB.Exec(
		context.Background(),
		query,
		course.CourseCode,  
		course.CourseName, 
		course.Status,     
		course.SemCode,    
		now,                
		now,            
	)
	if err != nil {
		log.Printf("Error inserting course record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert course record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Course record created successfully",
	})
}

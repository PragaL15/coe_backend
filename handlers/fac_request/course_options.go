package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

// Course struct maps to the course_table in the database
type Course struct {
	ID         int       `json:"id"`
	CourseID   int       `json:"course_id"`
	CourseCode string    `json:"course_code"`
	CourseName string    `json:"course_name"`
	Status     int       `json:"status"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// GetCoursesHandler retrieves all courses from the course_table
func GetCoursesHandler(c *fiber.Ctx) error {
	query := `SELECT id, course_id, course_code, course_name, status, createdat, updatedat FROM course_table`
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying course data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve course data",
		})
	}
	defer rows.Close()

	var courses []Course
	for rows.Next() {
		var course Course
		if err := rows.Scan(
			&course.ID,
			&course.CourseID,
			&course.CourseCode,
			&course.CourseName,
			&course.Status,
			&course.CreatedAt,
			&course.UpdatedAt,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse course data",
			})
		}

		courses = append(courses, course)
	}

	return c.Status(http.StatusOK).JSON(courses)
}

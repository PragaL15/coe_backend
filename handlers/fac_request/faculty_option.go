package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type Faculty struct {
	FacultyID   int       `json:"faculty_id"`
	FacultyName string    `json:"faculty_name"` // Non-pointer since faculty_name is NOT NULL
	Dept        int       `json:"dept"`
	Status      int       `json:"status"`
	CreatedAt   time.Time `json:"created_at"`   // Changed to time.Time to match the database type
	UpdatedAt   time.Time `json:"updated_at"`   // Changed to time.Time to match the database type
	MobileNum   string    `json:"mobile_num"`   // Non-pointer since mobile_num is NOT NULL
}

func GetFacultyHandler(c *fiber.Ctx) error {
	query := `SELECT faculty_id, faculty_name, dept, status, createdat, updatedat, mobile_num FROM faculty_table`
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying faculty data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve faculty data",
		})
	}
	defer rows.Close()

	var faculties []Faculty
	for rows.Next() {
		var faculty Faculty
		if err := rows.Scan(
			&faculty.FacultyID,
			&faculty.FacultyName,
			&faculty.Dept,
			&faculty.Status,
			&faculty.CreatedAt,
			&faculty.UpdatedAt,
			&faculty.MobileNum,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse faculty data",
			})
		}

		faculties = append(faculties, faculty)
	}

	return c.Status(http.StatusOK).JSON(faculties)
}
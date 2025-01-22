package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

// Semester struct represents the data structure of a semester
type Semester struct {
	ID              int       `json:"id"`
	SemCode         string    `json:"sem_code"`
	SemAcademicYear string    `json:"sem_academic_year"`
	Year            int       `json:"year"`
	Status          int       `json:"status"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

// GetSemestersHandler retrieves all semesters from the semester_table
func GetSemestersHandler(c *fiber.Ctx) error {
	query := `SELECT id, sem_code, sem_academic_year, year, status, createdat, updatedat FROM semester_table`
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying semester data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve semester data",
		})
	}
	defer rows.Close()

	var semesters []Semester
	for rows.Next() {
		var semester Semester
		if err := rows.Scan(
			&semester.ID,
			&semester.SemCode,
			&semester.SemAcademicYear,
			&semester.Year,
			&semester.Status,
			&semester.CreatedAt,
			&semester.UpdatedAt,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse semester data",
			})
		}
		semesters = append(semesters, semester)
	}

	return c.Status(http.StatusOK).JSON(semesters)
}

package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

// AcademicYear struct represents the data structure of an academic year
type AcademicYear struct {
	ID           int       `json:"id"`
	AcademicID   int       `json:"academic_id"` // Assuming academic_id is an integer
	AcademicYear string    `json:"academic_year"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// GetAcademicYearOptions retrieves all academic years from the academic_year_table
func GetAcademicYearOptions(c *fiber.Ctx) error {
	query := `SELECT id, academic_id, academic_year, created_at, updated_at FROM academic_year_table`
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying academic year data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve academic year data",
		})
	}
	defer rows.Close()

	var academicYears []AcademicYear
	for rows.Next() {
		var academicYear AcademicYear
		if err := rows.Scan(
			&academicYear.ID,
			&academicYear.AcademicID, // Ensure type matches the database column
			&academicYear.AcademicYear,
			&academicYear.CreatedAt,
			&academicYear.UpdatedAt,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse academic year data",
			})
		}
		academicYears = append(academicYears, academicYear)
	}

	return c.Status(http.StatusOK).JSON(academicYears)
}

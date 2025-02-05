package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type AcademicYear struct {
	ID           int       `json:"id"`
	AcademicYear string    `json:"academic_year"`
}
func GetAcademicYearOptions(c *fiber.Ctx) error {
	query := `SELECT id, academic_year FROM academic_year_table`
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
			&academicYear.AcademicYear,
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

package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

// Department struct maps to the dept_table in the database
type Department struct {
	ID        int       `json:"id"`
	DeptName  string    `json:"dept_name"`
	Status    int       `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// GetDepartmentsHandler retrieves all departments from the dept_table
func GetDepartmentsHandler(c *fiber.Ctx) error {
	query := `SELECT id, dept_name, status, createdat, updatedat FROM dept_table`
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying department data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve department data",
		})
	}
	defer rows.Close()

	var departments []Department
	for rows.Next() {
		var dept Department
		if err := rows.Scan(
			&dept.ID,
			&dept.DeptName,
			&dept.Status,
			&dept.CreatedAt,
			&dept.UpdatedAt,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse department data",
			})
		}

		departments = append(departments, dept)
	}

	return c.Status(http.StatusOK).JSON(departments)
}

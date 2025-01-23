package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type BCE struct {
	ID        int       `json:"id"`
	DeptID    int       `json:"dept_id"`
	BceID     string    `json:"bce_id"`
	BceName   string    `json:"bce_name"`
	Status    bool      `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func GetBceOptions(c *fiber.Ctx) error {
	query := `SELECT id, dept_id, bce_id, bce_name, status, createdat, updatedat FROM bce_table`
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying BCE data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve BCE data",
		})
	}
	defer rows.Close()

	var bceRecords []BCE
	for rows.Next() {
		var bce BCE
		if err := rows.Scan(
			&bce.ID,
			&bce.DeptID,
			&bce.BceID,
			&bce.BceName,
			&bce.Status,
			&bce.CreatedAt,
			&bce.UpdatedAt,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse BCE data",
			})
		}
		bceRecords = append(bceRecords, bce)
	}

	return c.Status(http.StatusOK).JSON(bceRecords)
}

package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type PaperID struct {
	ID      int    `json:"id"`     
	PaperID string `json:"paper_id"` 
}

func GetPaperIDHandler(c *fiber.Ctx) error {
	query := `SELECT id, paper_id FROM paper_id_table`

	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying paper_id_table: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve paper IDs",
		})
	}
	defer rows.Close()

	var paperIDs []PaperID
	for rows.Next() {
		var paper PaperID

		if err := rows.Scan(&paper.ID, &paper.PaperID); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse paper ID data",
			})
		}

		paperIDs = append(paperIDs, paper)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating rows: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Error processing paper ID data",
		})
	}

	return c.Status(http.StatusOK).JSON(paperIDs)
}

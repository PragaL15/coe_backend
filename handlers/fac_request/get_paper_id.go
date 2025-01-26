package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

// PaperID represents the structure of the paper ID data
type PaperID struct {
	ID      int    `json:"id"`      // ID
	PaperID string `json:"paper_id"` // Paper ID
}

// GetPaperIDHandler retrieves all paper IDs from the paper_id_table
func GetPaperIDHandler(c *fiber.Ctx) error {
	// Query to select all paper IDs
	query := `SELECT id, paper_id FROM paper_id_table`

	// Execute the query
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

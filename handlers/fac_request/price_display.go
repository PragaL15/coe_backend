package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type PriceCalculation struct {
	ID             int     `json:"id"`
	FacultyID      int     `json:"faculty_id"`
	PaperCorrected int     `json:"paper_corrected"`
	Price          float64 `json:"price"`
	AmtGiven       float64 `json:"amt_given"`
}

func GetPriceCalculationsHandler(c *fiber.Ctx) error {
	query := `
		SELECT id, faculty_id, paper_corrected, price, amt_given 
		FROM price_calculation
	`

	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying price_calculation data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve price calculation data",
		})
	}
	defer rows.Close()

	var calculations []PriceCalculation
	for rows.Next() {
		var calculation PriceCalculation
		if err := rows.Scan(
			&calculation.ID,
			&calculation.FacultyID,
			&calculation.PaperCorrected,
			&calculation.Price,
			&calculation.AmtGiven,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse price calculation data",
			})
		}
		calculations = append(calculations, calculation)
	}

	return c.Status(http.StatusOK).JSON(calculations)
}

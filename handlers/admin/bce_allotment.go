package Adminhandlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type BCEPost struct {
	DeptID  int    `json:"dept_id"`
	BceID   string `json:"bce_id"`
	BceName string `json:"bce_name"`
	Status  bool   `json:"status"`
}

func PostBceOptions(c *fiber.Ctx) error {
	var bce BCEPost
	if err := c.BodyParser(&bce); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if bce.DeptID <= 0 || bce.BceID == "" || bce.BceName == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input data. 'dept_id', 'bce_id', and 'bce_name' are required.",
		})
	}

	query := `
		INSERT INTO bce_table (dept_id, bce_id, bce_name, status, createdat, updatedat)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`

	now := time.Now()

	var insertedID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		bce.DeptID,
		bce.BceID,
		bce.BceName,
		bce.Status,
		now,
		now,
	).Scan(&insertedID)

	if err != nil {
		log.Printf("Error inserting BCE record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert BCE record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "BCE record created successfully",
		"id":      insertedID,
	})
}

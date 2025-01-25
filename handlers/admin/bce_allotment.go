package Adminhandlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type BCEPost struct {
	DeptID    int    `json:"dept_id"`
	BceID     string `json:"bce_id"`
	BceName   string `json:"bce_name"`
	Email     string `json:"email"`
	MobileNum string `json:"mobile_num"`
	Status    bool   `json:"status"`
}

func PostBceOptions(c *fiber.Ctx) error {
	var bce BCEPost
	if err := c.BodyParser(&bce); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if bce.DeptID <= 0 {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'dept_id' is required and must be greater than 0",
		})
	}
	if bce.BceID == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'bce_id' is required",
		})
	}
	if bce.BceName == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'bce_name' is required",
		})
	}
	if bce.Email == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'email' is required",
		})
	}
	if bce.MobileNum == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "'mobile_num' is required",
		})
	}

	if config.DB == nil {
		log.Println("Database connection is not initialized")
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Database connection error",
		})
	}

	query := `
		INSERT INTO bce_table (dept_id, bce_id, bce_name, status, email, mobile_num)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`

	var insertedID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		bce.DeptID,
		bce.BceID,
		bce.BceName,
		bce.Status,
		bce.Email,
		bce.MobileNum,
	).Scan(&insertedID)

	if err != nil {
		log.Printf("Error inserting BCE record: %v. Data: %+v", err, bce)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert BCE record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "BCE record created successfully",
		"id":      insertedID,
	})
}

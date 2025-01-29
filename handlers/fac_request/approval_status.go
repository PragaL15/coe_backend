package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type UpdateFacultyRequest struct {
	ID             int    `json:"id"`
	ApprovalStatus int    `json:"approval_status"`
	Reason         string `json:"reason"`
}

func UpdateFacultyRequestHandler(c *fiber.Ctx) error {
	var req UpdateFacultyRequest

	if err := c.BodyParser(&req); err != nil {
		log.Printf("Failed to parse request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	query := `
		UPDATE faculty_request
		SET approval_status = $1, reason = $2, updatedat = NOW()
		WHERE id = $3
	`

	_, err := config.DB.Exec(context.Background(), query, req.ApprovalStatus, req.Reason, req.ID)
	if err != nil {
		log.Printf("Failed to update faculty request: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update faculty request",
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Faculty request updated successfully",
	})
}

package Adminhandlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type Department struct {
	DeptID   int    `json:"id"`
	DeptName string `json:"dept_name"`
	Status   int    `json:"status,omitempty"` 
}

func PostDeptHandler(c *fiber.Ctx) error {
	var dept Department
	if err := c.BodyParser(&dept); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}
	if dept.DeptName == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input data. 'dept_name' is required.",
		})
	}

	if dept.Status == 0 {
		dept.Status = 1
	}

	query := `
		INSERT INTO dept_table (id, dept_name, status, createdat, updatedat)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id;
	`

	now := time.Now()

	var insertedID int
	err := config.DB.QueryRow(
		context.Background(),
		query,
		dept.DeptID,   
		dept.DeptName,    
		dept.Status,      
		now,             
		now,              
	).Scan(&insertedID) 

	if err != nil {
		log.Printf("Error inserting department record: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert department record into the database",
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Department record created successfully",
		"id":      insertedID,
	})
}


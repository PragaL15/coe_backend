package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type FacultyRequest struct {
	FacultyID          int    `json:"faculty_id"`
	TotalAllocatedPapers int  `json:"total_allocated_papers"`
	PapersLeft         int    `json:"papers_left"`
	CourseID           int    `json:"course_id"`
	Remarks            string `json:"remarks"`
	ApprovalStatus     int    `json:"approval_status"`
	Status             int    `json:"status"`
	DeadlineLeft       int    `json:"deadline_left"`
	SemCode            string `json:"sem_code"`
	SemAcademicYear    string `json:"sem_academic_year"`
	Year               int    `json:"year"`
}

func PostFacultyRequestHandler(c *fiber.Ctx) error {
	var request FacultyRequest
	if err := c.BodyParser(&request); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}
	query := `
		CALL insert_faculty_request($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`
	_, err := config.DB.Exec(
		context.Background(),
		query,
		request.FacultyID,
		request.TotalAllocatedPapers,
		request.PapersLeft,
		request.CourseID,
		request.Remarks,
		request.ApprovalStatus,
		request.Status,
		request.DeadlineLeft,
		request.SemCode,
		request.SemAcademicYear,
		request.Year,
	)
	if err != nil {
		log.Printf("Error inserting faculty request: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert faculty request",
		})
	}
	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Faculty request created successfully",
	})
}

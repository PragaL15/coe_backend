package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type FacultyGetRequest struct {
	ID              int        `json:"id"`
	FacultyID       int        `json:"faculty_id"`
	PapersLeft      int        `json:"papers_left"`
	CourseID        int        `json:"course_id"`
	Remarks         string     `json:"remarks"`
	ApprovalStatus  int        `json:"approval_status"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
	DeadlineLeft    int        `json:"deadline_left"`
	SemCode         string     `json:"sem_code"`
	Reason          *string    `json:"reason"` 
}

func GetFacultyRequestsHandler(c *fiber.Ctx) error {
	query := `
		SELECT 
			id, faculty_id, papers_left, course_id, remarks, 
			approval_status, createdat, updatedat, deadline_left, 
			sem_code, reason 
		FROM faculty_request`

	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying faculty_request data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve faculty request data",
		})
	}
	defer rows.Close()
	var requests []FacultyGetRequest
	for rows.Next() {
		var request FacultyGetRequest
		if err := rows.Scan(
			&request.ID,
			&request.FacultyID,
			&request.PapersLeft,
			&request.CourseID,
			&request.Remarks,
			&request.ApprovalStatus,
			&request.CreatedAt,
			&request.UpdatedAt,
			&request.DeadlineLeft,
			&request.SemCode,
			&request.Reason,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse faculty request data",
			})
		}
		requests = append(requests, request)
	}
	return c.Status(http.StatusOK).JSON(requests)
}

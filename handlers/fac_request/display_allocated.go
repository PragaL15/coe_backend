package handlers

import (
	"context"
	"log"
	"net/http"
	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

// FacultyAllRecords represents the structure of the faculty records data
type FacultyAllRecords struct {
	FacultyID      int       `json:"faculty_id"`        // Faculty ID
	CourseID       int       `json:"course_id"`         // Course ID
	PaperAllocated int       `json:"paper_allocated"`   // Paper Allocated
	Deadline       int       `json:"deadline"`          // Deadline
	Status         int       `json:"status"`            // Status
	BCEID          string    `json:"bce_id"`            // BCE ID
	SemCode        string    `json:"sem_code"`          // Semester Code
	DeptID         int       `json:"dept_id"`           // Department ID
	PaperCorrected int       `json:"paper_corrected"`   // Paper Corrected
	PaperPending   int       `json:"paper_pending"`     // Paper Pending (calculated as paper_allocated - paper_corrected)
	PaperID        int   `json:"paper_id"`          // Paper ID
}

func GetAllFacultyRecordsHandler(c *fiber.Ctx) error {
	query := `
		SELECT 
			far.faculty_id,
			far.course_id,
			far.paper_allocated,
			far.deadline,
			far.status,
			far.bce_id,
			far.sem_code,
			far.dept_id,
			far.paper_corrected,
			far.paper_allocated - far.paper_corrected AS paper_pending, -- Calculated field
			far.paper_id
		FROM 
			faculty_all_records far
		JOIN 
			course_table ct ON far.course_id = ct.course_id
		JOIN 
			paper_id_table pit ON CAST(far.paper_id AS INTEGER) = pit.id
	`

	// Execute the query
	rows, err := config.DB.Query(context.Background(), query)
	if err != nil {
		log.Printf("Error querying faculty_all_records data: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve faculty records",
		})
	}
	defer rows.Close()

	var facultyRecords []FacultyAllRecords
	for rows.Next() {
		var record FacultyAllRecords

		if err := rows.Scan(
			&record.FacultyID,
			&record.CourseID,
			&record.PaperAllocated,
			&record.Deadline,
			&record.Status,
			&record.BCEID,
			&record.SemCode,
			&record.DeptID,
			&record.PaperCorrected,
			&record.PaperPending, 
			&record.PaperID,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse faculty records data",
			})
		}

		facultyRecords = append(facultyRecords, record)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating rows: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Error processing faculty records data",
		})
	}

	return c.Status(http.StatusOK).JSON(facultyRecords)
}

package handlers

import (
	"context"
	"log"
	"net/http"
	"github.com/gofiber/fiber/v2"
	"github.com/PragaL15/coe_backend/config"
)

type FacultyAllRecords struct {
	FacultyID      int       `json:"faculty_id"`      
	CourseID       int       `json:"course_id"`        
	PaperAllocated int       `json:"paper_allocated"`   
	Deadline       int       `json:"deadline"`          
	Status         int       `json:"status"`            
	BCEID          string    `json:"bce_id"`            
	SemCode        string    `json:"sem_code"`          
	DeptID         int       `json:"dept_id"`          
	PaperCorrected int       `json:"paper_corrected"`  
	PaperPending   int       `json:"paper_pending"`    
	PaperID        int   `json:"paper_id"`         
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

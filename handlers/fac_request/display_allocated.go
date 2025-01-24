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
	FacultyID      int    `json:"faculty_id"`
	CourseName     string `json:"course_name"`  // To fetch the course name
	PaperAllocated int    `json:"paper_allocated"`
	Deadline       int    `json:"deadline"`
	Status         int    `json:"status"`
	BCEID          string `json:"bce_id"`
	SemCode        string `json:"sem_code"`
	DeptName       string `json:"dept_name"`    // To fetch the department name
	DeptID         int    `json:"dept_id"`      // To fetch the department ID
}

// GetAllFacultyRecordsHandler fetches all faculty records with course and department details
func GetAllFacultyRecordsHandler(c *fiber.Ctx) error {
	// Updated SQL query with correct joins
	query := `
		SELECT 
			far.faculty_id,
			ct.course_name,
			far.paper_allocated,
			far.deadline,
			far.status,
			far.bce_id,
			far.sem_code,
			dt.dept_name,
			dt.id AS dept_id
		FROM 
			faculty_all_records far
		JOIN 
			course_table ct ON far.course_id = ct.course_id
		JOIN 
			dept_table dt ON far.dept_id = dt.id
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

	// Parse the result rows into a slice of FacultyAllRecords
	var facultyRecords []FacultyAllRecords
	for rows.Next() {
		var record FacultyAllRecords
		if err := rows.Scan(
			&record.FacultyID,
			&record.CourseName,
			&record.PaperAllocated,
			&record.Deadline,
			&record.Status,
			&record.BCEID,
			&record.SemCode,
			&record.DeptName,
			&record.DeptID,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse faculty records data",
			})
		}
		facultyRecords = append(facultyRecords, record)
	}

	// Check for any errors during iteration
	if err := rows.Err(); err != nil {
		log.Printf("Error iterating rows: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Error processing faculty records data",
		})
	}

	// Return the fetched records as JSON
	return c.Status(http.StatusOK).JSON(facultyRecords)
}

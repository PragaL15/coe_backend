package routes

import (
	handlers "github.com/PragaL15/coe_backend/handlers/fac_request"
	Adminhandlers "github.com/PragaL15/coe_backend/handlers/admin"
	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	facultyGroup := app.Group("/api")
	facultyGroup.Get("/faculty", handlers.GetFacultyHandler)
	facultyGroup.Get("/PriceFaculty", handlers.GetPriceCalculationsHandler)
	facultyGroup.Get("/courseOption", handlers.GetCoursesHandler)
	facultyGroup.Get("/deptOption", handlers.GetDepartmentsHandler)
	facultyGroup.Get("/semOption", handlers.GetSemestersHandler)
	facultyGroup.Get("/academicOption", handlers.GetAcademicYearOptions)
	facultyGroup.Get("/bceOption", handlers.GetBceOptions)
	facultyGroup.Get("/paperIDoption", handlers.GetPaperIDHandler)
	facultyGroup.Get("/FacultyGetApprove", handlers.GetFacultyRequestsHandler)
	facultyGroup.Get("/FacultyRecordsDisplay", handlers.GetAllFacultyRecordsHandler)
	facultyGroup.Post("/FacultyRequestSubmit", handlers.PostFacultyRequestHandler)
	facultyGroup.Post("/FacultyDailyUpdate", handlers.PostFacultyDailyUpdateHandler)
	facultyGroup.Post("/FacultyApproval", handlers.UpdateFacultyRequestHandler)
	facultyGroup.Post("/BoardApproval", handlers.PostFacultyBoardRequestHandler)

	adminGroup := app.Group("/api")
	adminGroup.Post("/BceData", Adminhandlers.PostBceOptions)
	adminGroup.Post("/CourseSend", Adminhandlers.PostCourseHandler)
	adminGroup.Post("/FacultyData", Adminhandlers.PostFacultyHandler)
	adminGroup.Post("/DeptData", Adminhandlers.PostDeptHandler)
	adminGroup.Post("/SemesterData", Adminhandlers.PostSemesterHandler)
	adminGroup.Post("/AcademicYearHandler", Adminhandlers.PostAcademicYearHandler)
}

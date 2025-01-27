package routes

import (
	handlers "github.com/PragaL15/coe_backend/handlers/fac_request"
	Loginhandlers "github.com/PragaL15/coe_backend/handlers"
	Adminhandlers "github.com/PragaL15/coe_backend/handlers/admin"
	middlewares "github.com/PragaL15/coe_backend/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Post("/login", Loginhandlers.LoginHandler)


	// Faculty Routes (role_id 2, 3)
	facultyGroup := app.Group("/api/faculty", middlewares.RoleBasedAuthGroup([]int{2, 3}))
	facultyGroup.Get("/faculty", handlers.GetFacultyHandler)
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
	facultyGroup.Post("/FacultyApproval",handlers.UpdateFacultyRequestHandler)
	facultyGroup.Post("/BoardApproval", handlers.PostFacultyBoardRequestHandler)

	// Admin Routes (role_id 1)
	adminGroup := app.Group("/api/admin", middlewares.RoleBasedAuth(1))
	adminGroup.Post("/BceData", Adminhandlers.PostBceOptions)
	adminGroup.Post("/CourseSend", Adminhandlers.PostCourseHandler)
	adminGroup.Post("/FacultyData", Adminhandlers.PostFacultyHandler)
	adminGroup.Post("/DeptData", Adminhandlers.PostDeptHandler)
	adminGroup.Post("/SemesterData", Adminhandlers.PostSemesterHandler)
	adminGroup.Post("/AcademicYearHandler", Adminhandlers.PostAcademicYearHandler)
}

package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/PragaL15/coe_backend/config"
	Adminhandlers "github.com/PragaL15/coe_backend/handlers/admin"
	"github.com/PragaL15/coe_backend/handlers/fac_request"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found, using environment variables")
	}
	config.ConnectDB()
	defer config.CloseDB()

	app := fiber.New()
	app.Use(logger.New())

	// CORS Middleware
	app.Use(cors.New(cors.Config{
		AllowOrigins:     "*",                // Allow all origins for simplicity
		AllowMethods:     "GET,POST,PUT,DELETE",
		AllowHeaders:     "Origin, Content-Type, Accept, Authorization",

	}))

	// Routes
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})
	app.Get("/api/faculty", handlers.GetFacultyHandler)
	app.Get("/api/courseOption", handlers.GetCoursesHandler)
	app.Get("/api/deptOption", handlers.GetDepartmentsHandler)
	app.Get("/api/semOption", handlers.GetSemestersHandler)
	app.Get("/api/academicOption", handlers.GetAcademicYearOptions)
	app.Get("/api/bceOption", handlers.GetBceOptions)
	app.Get("/api/FacultyGetApprove", handlers.GetFacultyRequestsHandler)
	app.Get("/api/FacultyRecordsDisplay", handlers.GetAllFacultyRecordsHandler)
	app.Post("/api/FacultyRequestSubmit", handlers.PostFacultyRequestHandler)
	app.Post("/api/FacultyApproval", handlers.UpdateFacultyRequestHandler)
	app.Post("/api/BoardApproval", handlers.PostFacultyBoardRequestHandler)
	app.Post("/api/BceData", Adminhandlers.PostBceOptions)
	app.Post("/api/CourseSend", Adminhandlers.PostCourseHandler)
	app.Post("/api/FacultyData", Adminhandlers.PostFacultyHandler)
	app.Post("/api/DeptData", Adminhandlers.PostDeptHandler)
	app.Post("/api/SemesterData", Adminhandlers.PostSemesterHandler)
	app.Post("/api/AcademicYearHandler", Adminhandlers.PostAcademicYearHandler)
 
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		log.Println("Gracefully shutting down...")
		_ = app.Shutdown()
	}()

	port := os.Getenv("PORT")
	if port == "" {
		port = "4000"
	}
	log.Printf("Server running on port %s", port)
	log.Fatal(app.Listen(":" + port))
}

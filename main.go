package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/PragaL15/coe_backend/config"
	routes "github.com/PragaL15/coe_backend/routers"
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
	app.Use(cors.New(cors.Config{
		AllowOrigins: "http://localhost:5173", 
		AllowMethods: "GET,POST,PUT,DELETE",  
		AllowCredentials: true,                   
		AllowHeaders: "Origin, Content-Type, Accept, Authorization", 
	}))

	routes.SetupRoutes(app)

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

package Loginhandlers

import (
	"database/sql"
	"errors"
	"github.com/PragaL15/coe_backend/config"
	"github.com/PragaL15/coe_backend/utils"
	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
	"time"
	"log"
)

type LoginRequest struct {
	Username string `json:"user_name"` 
	Password string `json:"password"`   
}

type LoginResponse struct {
	UserID  int    `json:"user_id"`
	RoleID  int    `json:"role_id"`
	Message string `json:"message"`
}

func LoginHandler(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	var (
		userID   int
		roleID   int
		status   bool
		hashedPW string
	)

	query := `SELECT user_id, role_id, password, status FROM user_table WHERE user_name = $1`
	err := config.DB.QueryRow(c.Context(), query, req.Username).Scan(&userID, &roleID, &hashedPW, &status)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			log.Println("Invalid username or password")
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid username or password"})
		}
		log.Printf("Error querying database: %v", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Internal server error"})
	}

	if !status {
		log.Println("Account is inactive")
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Account is inactive"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(hashedPW), []byte(req.Password)); err != nil {
		log.Println("Invalid password")
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid username or password"})
	}

	token, err := utils.GenerateToken(userID, roleID)
	if err != nil {
		log.Printf("Error generating token: %v", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to generate token"})
	}
	tokenExpiration := time.Now().Add(24 * time.Hour)  
	c.Cookie(&fiber.Cookie{
		Name:     "auth_token",
		Value:    token,
		HTTPOnly: true,
		Secure:   false,  
		SameSite: "Strict",
		Expires:  tokenExpiration,
	})
	return c.Status(fiber.StatusOK).JSON(LoginResponse{
		UserID:  userID,
		RoleID:  roleID,
		Message: "Login successful",
	})
}

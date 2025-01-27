package utils

import (
	"time"
	"github.com/golang-jwt/jwt/v4"
	"os"
	"log"
	"fmt"
)

func GenerateToken(userID int, roleID int) (string, error) {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET environment variable is not set")
		return "", fmt.Errorf("JWT_SECRET environment variable is not set")
	}
	claims := jwt.MapClaims{
		"user_id": userID,
		"role_id": roleID,
		"exp":     time.Now().Add(time.Hour * 1).Unix(),  
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		return "", fmt.Errorf("failed to sign the token: %w", err)
	}

	return signedToken, nil
}

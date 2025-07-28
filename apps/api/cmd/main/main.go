package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/mux"
	"github.com/harshq/planet-marketplace/apps/api/internal/config"
	"github.com/harshq/planet-marketplace/apps/api/internal/db"
	"github.com/harshq/planet-marketplace/apps/api/internal/handlers"
	"github.com/harshq/planet-marketplace/apps/api/internal/repositories"
	"github.com/harshq/planet-marketplace/apps/api/internal/services"
)

func main() {
	logger := log.New(os.Stdout, "[ @planet/api ] ", log.LstdFlags)
	ctx := context.Background()

	cfg, err := config.LoadConfig(ctx)
	if err != nil {
		logger.Fatalf("Failed to load config: %v", err)
	}

	dbs, err := db.Connect(cfg)
	if err != nil {
		logger.Fatalf("failed to connect database: %v", err)
	}

	// ping
	pingHandler := handlers.NewPingHandler(logger)

	// listing
	listingRepo := repositories.NewListingRepository(logger, dbs)
	listingService := services.NewListingService(logger, listingRepo)
	listingHandler := handlers.NewListingHandler(logger, listingService)

	mux := mux.NewRouter()
	v1 := mux.PathPrefix("/api/v1").Subrouter()

	v1.HandleFunc("/listing/{state}", listingHandler.GetListings).Methods(http.MethodGet)
	v1.HandleFunc("/ping", pingHandler.Pong).Methods(http.MethodGet)

	server := http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt)

	go func() {
		logger.Println("Starting server on :8080")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Printf("Server error: %v", err)
		}
	}()

	<-sigChan
	context, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	db.Close()

	if err := server.Shutdown(context); err != nil && err != http.ErrServerClosed {
		logger.Fatalf("Shutdown failed %v", err)
	}

	logger.Println("Server shutdown successful")

}

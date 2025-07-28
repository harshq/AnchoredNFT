package services

import (
	"fmt"
	"log"

	"github.com/harshq/planet-marketplace/apps/api/internal/models"
	"github.com/harshq/planet-marketplace/apps/api/internal/repositories"
)

type ListingService struct {
	logger      *log.Logger
	listingRepo *repositories.ListingRepository
}

func NewListingService(logger *log.Logger, listingRepo *repositories.ListingRepository) *ListingService {
	return &ListingService{
		logger:      logger,
		listingRepo: listingRepo,
	}
}

func (ls *ListingService) FetchListings(state string) ([]models.ItemListed, error) {
	switch state {
	case "active":
		return ls.listingRepo.GetActiveListings()
	default:
		ls.logger.Printf("invalid state: %s", state)
		return nil, fmt.Errorf("invalid state: %s", state)
	}
}

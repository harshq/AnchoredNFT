package repositories

import (
	"fmt"
	"log"

	"github.com/harshq/planet-marketplace/apps/api/internal/models"
	"gorm.io/gorm"
)

type ListingRepository struct {
	logger *log.Logger
	db     *gorm.DB
}

func NewListingRepository(logger *log.Logger, db *gorm.DB) *ListingRepository {
	return &ListingRepository{
		logger: logger,
		db:     db,
	}
}

func (lr *ListingRepository) GetActiveListings() ([]models.ItemListed, error) {
	var activeListings []models.ItemListed = []models.ItemListed{}

	query := `
		SELECT l.*
		FROM marketplace_nft_marketplace.item_listed l
		WHERE NOT EXISTS (
		SELECT 1 FROM marketplace_nft_marketplace.item_sold s
		WHERE s.contract_address = l.contract_address
			AND s.token_address = l.token_address
			AND s.token_id = l.token_id
		)
		AND NOT EXISTS (
		SELECT 1 FROM marketplace_nft_marketplace.item_delisted d
		WHERE d.contract_address = l.contract_address
			AND d.token_address = l.token_address
			AND d.token_id = l.token_id
		)
	`

	if err := lr.db.Raw(query).Scan(&activeListings).Error; err != nil {
		lr.logger.Printf("error repository: %v", err)
		return nil, fmt.Errorf("error repository: %v", err)
	}

	// if len(activeListings) == 0 {
	// 	return []models.ItemListed{},
	// }

	return activeListings, nil
}

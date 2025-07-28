package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/harshq/planet-marketplace/apps/api/internal/services"
	"github.com/harshq/planet-marketplace/apps/api/pkg/httpresp"
)

type ListingHandler struct {
	logger         *log.Logger
	listingService *services.ListingService
}

func NewListingHandler(logger *log.Logger, listingService *services.ListingService) *ListingHandler {
	return &ListingHandler{
		logger:         logger,
		listingService: listingService,
	}
}

func (lh *ListingHandler) GetListings(rw http.ResponseWriter, r *http.Request) {
	state := mux.Vars(r)["state"]
	listings, err := lh.listingService.FetchListings(state)
	if err != nil {
		lh.logger.Printf("error fetching data: %v", err)
		httpresp.WriteJSONError(rw, http.StatusBadRequest, fmt.Sprintf("error fetching data: %v", err))
		return
	}

	rw.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(rw).Encode(listings)
	if err != nil {
		lh.logger.Printf("error encoding data: %v", err)
		httpresp.WriteJSONError(rw, http.StatusInternalServerError, fmt.Sprintf("error encoding data: %v", err))
		return
	}
}

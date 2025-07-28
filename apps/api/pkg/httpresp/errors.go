package httpresp

import (
	"encoding/json"
	"net/http"
)

func WriteJSONError(rw http.ResponseWriter, status int, message string) {
	rw.Header().Set("Content-Type", "application/json")
	rw.WriteHeader(status)
	json.NewEncoder(rw).Encode(map[string]string{"error": message})
}

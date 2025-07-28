package handlers

import (
	"io"
	"log"
	"net/http"
)

type PingHandler struct {
	logger *log.Logger
}

func NewPingHandler(logger *log.Logger) *PingHandler {
	return &PingHandler{
		logger: logger,
	}
}

func (p *PingHandler) Pong(rw http.ResponseWriter, r *http.Request) {
	rw.Header().Set("content-type", "application/json")
	rw.WriteHeader(http.StatusOK)
	io.WriteString(rw, `{"status":"pong"}`)
}

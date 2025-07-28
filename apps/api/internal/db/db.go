package db

import (
	"sync"
	"time"

	"github.com/harshq/planet-marketplace/apps/api/internal/config"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var (
	err  error
	conn *gorm.DB
	once sync.Once
)

func Connect(cfg *config.Config) (*gorm.DB, error) {
	// we want to run this only once
	once.Do(func() {
		conn, err = gorm.Open(postgres.Open(cfg.DB_URL), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Warn),
		})

	})

	sqldb, connErr := conn.DB()
	if connErr != nil {
		err = connErr
	}

	// sql db config
	sqldb.SetMaxOpenConns(25)
	sqldb.SetMaxIdleConns(10)
	sqldb.SetConnMaxLifetime(30 * time.Minute)

	return conn, err
}

func Close() error {
	// nothing to close
	if conn == nil {
		return nil
	}

	// get actual db
	sqldb, err := conn.DB()
	if err != nil {
		return err
	}

	return sqldb.Close()
}

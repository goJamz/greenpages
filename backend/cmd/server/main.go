package main

import (
	"context"
	"embed"
	"fmt"
	"log"
	"net/http"
	"os"
	"sort"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/jackc/pgx/v5/pgxpool"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

//go:embed seeds/*.sql
var seedsFS embed.FS

func main() {
	cmd := "serve"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer pool.Close()

	switch cmd {
	case "migrate":
		runMigrations(ctx, pool)
	case "seed":
		runSeeds(ctx, pool)
	case "serve":
		runMigrations(ctx, pool)
		startServer(pool)
	default:
		log.Fatalf("Unknown command: %s", cmd)
	}
}

func runMigrations(ctx context.Context, pool *pgxpool.Pool) {
	entries, err := migrationsFS.ReadDir("migrations")
	if err != nil {
		log.Fatalf("Failed to read migrations: %v", err)
	}

	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name() < entries[j].Name()
	})

	// Create migrations tracking table
	_, err = pool.Exec(ctx, `
		CREATE TABLE IF NOT EXISTS schema_migrations (
			filename TEXT PRIMARY KEY,
			applied_at TIMESTAMPTZ DEFAULT NOW()
		)
	`)
	if err != nil {
		log.Fatalf("Failed to create migrations table: %v", err)
	}

	for _, entry := range entries {
		if !strings.HasSuffix(entry.Name(), ".sql") {
			continue
		}

		// Check if already applied
		var exists bool
		err = pool.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE filename=$1)", entry.Name()).Scan(&exists)
		if err != nil {
			log.Fatalf("Failed to check migration %s: %v", entry.Name(), err)
		}
		if exists {
			fmt.Printf("  skip: %s (already applied)\n", entry.Name())
			continue
		}

		sql, err := migrationsFS.ReadFile("migrations/" + entry.Name())
		if err != nil {
			log.Fatalf("Failed to read migration %s: %v", entry.Name(), err)
		}

		_, err = pool.Exec(ctx, string(sql))
		if err != nil {
			log.Fatalf("Failed to run migration %s: %v", entry.Name(), err)
		}

		_, err = pool.Exec(ctx, "INSERT INTO schema_migrations (filename) VALUES ($1)", entry.Name())
		if err != nil {
			log.Fatalf("Failed to record migration %s: %v", entry.Name(), err)
		}

		fmt.Printf("  applied: %s\n", entry.Name())
	}
	fmt.Println("Migrations complete.")
}

func runSeeds(ctx context.Context, pool *pgxpool.Pool) {
	entries, err := seedsFS.ReadDir("seeds")
	if err != nil {
		log.Fatalf("Failed to read seeds: %v", err)
	}

	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name() < entries[j].Name()
	})

	for _, entry := range entries {
		if !strings.HasSuffix(entry.Name(), ".sql") {
			continue
		}
		sql, err := seedsFS.ReadFile("seeds/" + entry.Name())
		if err != nil {
			log.Fatalf("Failed to read seed %s: %v", entry.Name(), err)
		}
		_, err = pool.Exec(ctx, string(sql))
		if err != nil {
			log.Fatalf("Failed to run seed %s: %v", entry.Name(), err)
		}
		fmt.Printf("  seeded: %s\n", entry.Name())
	}
	fmt.Println("Seeding complete.")
}

func startServer(pool *pgxpool.Pool) {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins: []string{"http://localhost:5173"},
		AllowedMethods: []string{"GET", "OPTIONS"},
		AllowedHeaders: []string{"Content-Type", "Authorization"},
	}))

	r.Get("/api/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"ok"}`))
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server listening on :%s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}

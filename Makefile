.PHONY: up down build logs ps migrate seed reset

# Local development
up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f

ps:
	docker compose ps

# Database
migrate:
	docker compose exec backend /app/server migrate

seed:
	docker compose exec backend /app/server seed

reset:
	docker compose down -v
	docker compose up -d
	@echo "Waiting for postgres..."
	@sleep 3
	$(MAKE) migrate
	$(MAKE) seed

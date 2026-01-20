.PHONY: help start stop restart logs health init backup network test clean

# Colors
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m # No Color

help:
	@echo "$(GREEN)================================$(NC)"
	@echo "HealthCare Now - DevOps Makefile"
	@echo "$(GREEN)================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Available Commands:$(NC)"
	@echo ""
	@echo "$(GREEN)Startup:$(NC)"
	@echo "  make start              - Start all services"
	@echo "  make stop               - Stop all services"
	@echo "  make restart            - Restart all services"
	@echo ""
	@echo "$(GREEN)Monitoring & Debugging:$(NC)"
	@echo "  make logs [service]     - View logs (e.g., make logs service=nginx)"
	@echo "  make health             - Health check all services"
	@echo "  make network            - Network diagnostics"
	@echo "  make status             - Show container status"
	@echo ""
	@echo "$(GREEN)Database:$(NC)"
	@echo "  make init               - Initialize databases"
	@echo "  make backup             - Backup all databases"
	@echo ""
	@echo "$(GREEN)Build & Deploy:$(NC)"
	@echo "  make build              - Build docker images"
	@echo "  make pull               - Pull latest images"
	@echo ""
	@echo "$(GREEN)Cleanup:$(NC)"
	@echo "  make clean              - Remove containers (keep volumes)"
	@echo "  make clean-all          - Remove containers & volumes"
	@echo "  make prune              - Remove unused docker resources"
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@echo "  make test               - Run tests"
	@echo ""

start:
	@echo "$(GREEN)Starting all services...$(NC)"
	@bash scripts/start-all.sh

stop:
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@bash scripts/stop-all.sh

restart:
	@echo "$(YELLOW)Restarting all services...$(NC)"
	@bash scripts/restart-all.sh

logs:
	@if [ -z "$(service)" ]; then \
		echo "$(RED)Error: Please specify service$(NC)"; \
		echo "Usage: make logs service=nginx"; \
		docker-compose ps | tail -n +2 | awk '{print "  - " $$1}'; \
	else \
		docker-compose logs -f $(service); \
	fi

health:
	@echo "$(GREEN)Running health check...$(NC)"
	@bash scripts/health-check.sh

network:
	@echo "$(GREEN)Running network diagnostics...$(NC)"
	@bash scripts/network-diagnostics.sh

status:
	@echo "$(GREEN)Container Status:$(NC)"
	@docker-compose ps

init:
	@echo "$(GREEN)Initializing databases...$(NC)"
	@bash scripts/init-databases.sh

backup:
	@echo "$(GREEN)Backing up databases...$(NC)"
	@bash scripts/backup-databases.sh

build:
	@echo "$(GREEN)Building docker images...$(NC)"
	@docker-compose build

pull:
	@echo "$(GREEN)Pulling latest images...$(NC)"
	@docker-compose pull

clean:
	@echo "$(YELLOW)Cleaning up containers...$(NC)"
	@docker-compose down

clean-all:
	@echo "$(RED)Removing all containers and volumes...$(NC)"
	@docker-compose down -v

prune:
	@echo "$(YELLOW)Pruning unused docker resources...$(NC)"
	@docker system prune -f

test:
	@echo "$(GREEN)Running tests...$(NC)"
	@echo "API Gateway health check..."
	@curl -s http://localhost/health || echo "$(RED)API Gateway not responding$(NC)"
	@echo ""
	@echo "Prometheus health check..."
	@curl -s http://localhost:9090/-/healthy || echo "$(RED)Prometheus not responding$(NC)"
	@echo ""
	@echo "Grafana health check..."
	@curl -s http://localhost:3000/api/health | grep -q "ok" && echo "$(GREEN)✓ Grafana is healthy$(NC)" || echo "$(RED)Grafana not responding$(NC)"
	@echo ""

# Shortcuts
ps: status
l: logs
h: health
r: restart

# Development helpers
dev-start: start init health
	@echo "$(GREEN)Development environment ready!$(NC)"
	@echo "Grafana: http://localhost:3000/grafana"
	@echo "Prometheus: http://localhost:9090"
	@echo "API: http://localhost"

dev-logs:
	@docker-compose logs -f --tail=50 \
		core_db iot_db redis rabbitmq \
		prometheus grafana nginx

shell-core-db:
	@docker-compose exec core_db mongosh

shell-iot-db:
	@docker-compose exec iot_db mongosh

shell-redis:
	@docker-compose exec redis redis-cli

shell-rabbitmq:
	@docker-compose exec rabbitmq bash

# Container inspection
inspect-nginx:
	@docker inspect nginx | jq '.[0].NetworkSettings.Networks'

inspect-prometheus:
	@docker inspect prometheus | jq '.[0].Config.Env[] | select(. | contains("prometheus"))'

# Port checking
ports:
	@echo "$(GREEN)Active Ports:$(NC)"
	@netstat -tlnp 2>/dev/null | grep -E "LISTEN|tcp" || lsof -i -P -n | grep LISTEN

.DEFAULT_GOAL := help

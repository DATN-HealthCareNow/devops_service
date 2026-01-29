#!/bin/bash

#===== HEALTHCARE NOW SYSTEM - START SCRIPT =====
# Script để khởi chạy toàn bộ hệ thống với một lệnh duy nhất

set -e  # Exit on error

echo "=================================================="
echo "🏥 HealthCare Now System - Starting All Services"
echo "=================================================="
echo ""

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed"
    exit 1
fi

# Check if Docker daemon is running
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Error: Docker daemon is not running"
    exit 1
fi

# Navigate to script directory (parent of scripts folder)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

echo "📁 Project directory: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found, creating from .env.example"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✓ Created .env from .env.example"
    else
        echo "❌ Error: .env.example not found"
        exit 1
    fi
fi

echo ""
echo "🐳 Pulling latest images..."
docker-compose pull

echo ""
echo "🚀 Starting all services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start (10 seconds)..."
sleep 10

echo ""
echo "📋 Checking service status..."
docker-compose ps

echo ""
echo "=================================================="
echo "✅ All services started successfully!"
echo "=================================================="
echo ""
echo "📍 Access points:"
echo "   • API Gateway:        http://localhost"
echo "   • PgAdmin (DB UI):    http://localhost:5050"
echo "   • Grafana Dashboard:  http://localhost:3000/grafana"
echo "   • Prometheus:         http://localhost:9090"
echo ""
echo "🔧 Useful commands:"
echo "   • View logs:          docker-compose logs -f"
echo "   • Stop all:           docker-compose down"
echo "   • Restart service:    docker-compose restart <service_name>"
echo ""
echo "💡 Next steps:"
echo "   1. Build and push your microservice images"
echo "   2. Update docker-compose.yml with your service images"
echo "   3. Run: docker-compose up -d"
echo ""

#!/bin/bash

#===== HEALTHCARE NOW SYSTEM - RESTART SCRIPT =====
# Script để khởi động lại toàn bộ hệ thống

set -e

echo "=================================================="
echo "🏥 HealthCare Now System - Restarting All Services"
echo "=================================================="
echo ""

# Navigate to script directory (parent of scripts folder)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR"

echo "🛑 Stopping all services..."
docker-compose down

echo ""
echo "⏳ Waiting before restart (5 seconds)..."
sleep 5

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
echo "✅ All services restarted successfully!"
echo "=================================================="
echo ""

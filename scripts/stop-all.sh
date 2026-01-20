#!/bin/bash

#===== HEALTHCARE NOW SYSTEM - STOP SCRIPT =====
# Script để dừng toàn bộ hệ thống

set -e

echo "=================================================="
echo "🏥 HealthCare Now System - Stopping All Services"
echo "=================================================="
echo ""

# Navigate to script directory (parent of scripts folder)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR"

echo "🛑 Stopping all services..."
docker-compose down

echo ""
echo "=================================================="
echo "✅ All services stopped successfully!"
echo "=================================================="
echo ""

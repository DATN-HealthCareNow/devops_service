#!/bin/bash

#===== HEALTH CHECK SCRIPT =====
# Script kiểm tra trạng thái tất cả các service

set -e

echo "=================================================="
echo "🏥 HealthCare Now System - Health Check"
echo "=================================================="
echo ""

# Function to check service health
check_service() {
    local name=$1
    local url=$2
    
    echo -n "Checking $name... "
    
    if curl -s "$url" > /dev/null 2>&1; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

# Function to check container status
check_container() {
    local name=$1
    
    echo -n "Checking container $name... "
    
    if docker ps | grep -q "$name"; then
        echo "✅ Running"
        return 0
    else
        echo "❌ Not Running"
        return 1
    fi
}

echo "🐳 Container Status:"
check_container "core_db"
check_container "iot_db"
check_container "redis"
check_container "rabbitmq"
check_container "nginx"
check_container "postgres"
check_container "pgadmin"
check_container "prometheus"
check_container "grafana"

echo ""
echo "🌐 Service Health:"
check_service "Nginx Gateway" "http://localhost/health" || true
check_service "Prometheus" "http://localhost:9090/-/healthy" || true
check_service "Grafana" "http://localhost:3000/api/health" || true

echo ""
echo "🐘 Database Connectivity:"
echo -n "Checking PostgreSQL connection... "
if docker exec postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ Ready"
else
    echo "❌ Not Ready"
fi

echo ""
echo "📊 Docker Container Resources:"
docker stats --no-stream

echo ""
echo "=================================================="
echo "✅ Health check completed!"
echo "=================================================="
echo ""

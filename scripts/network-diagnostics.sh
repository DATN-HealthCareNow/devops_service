#!/bin/bash

#===== NETWORK DIAGNOSTICS SCRIPT =====
# Script kiểm tra network giữa các container

set -e

echo "=================================================="
echo "🔍 HealthCare Now System - Network Diagnostics"
echo "=================================================="
echo ""

echo "📊 Docker Network Status:"
docker network inspect healthcare-network 2>/dev/null | \
    grep -A 5 '"Containers"' || echo "⚠️  Network not found or not connected"

echo ""
echo "📡 Container Connectivity Test:"
echo ""

# Test connectivity between containers
test_connection() {
    local from=$1
    local to=$2
    local port=$3
    
    echo -n "Testing $from → $to:$port... "
    
    if docker exec "$from" timeout 3 bash -c "echo > /dev/tcp/$to/$port" 2>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
    fi
}

# Test key connections
test_connection "nginx" "core_db" "27017"
test_connection "nginx" "iot_db" "27017"
test_connection "nginx" "rabbitmq" "5672"
test_connection "nginx" "redis" "6379"
test_connection "prometheus" "nginx" "80"
test_connection "grafana" "prometheus" "9090"

echo ""
echo "🔍 DNS Resolution Test:"
docker exec nginx nslookup core_db 2>&1 | tail -5

echo ""
echo "📋 Docker Network Summary:"
echo ""
docker exec nginx netstat -an 2>/dev/null | grep ESTABLISHED | wc -l
echo "Active connections on nginx"

echo ""
echo "=================================================="
echo "✅ Network diagnostics completed!"
echo "=================================================="

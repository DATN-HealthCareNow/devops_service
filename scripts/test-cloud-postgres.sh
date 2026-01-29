#!/bin/bash

#===== CLOUD POSTGRES CONNECTION TESTER =====
# Script để kiểm tra kết nối tới AWS RDS / Cloud Postgres
# Usage: ./test-cloud-postgres.sh <postgres_uri> OR use .env

set -e

# Load .env variables if present
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Determine connection params
URI="${1:-$POSTGRES_URI}"

echo "=================================================="
echo "☁️  CLOUD POSTGRESQL CONNECTIVITY TEST"
echo "=================================================="

if [ -z "$URI" ]; then
    echo "❌ Error: POSTGRES_URI not found!"
    echo "   1. Add POSTGRES_URI to your .env file"
    echo "   2. OR run: ./test-cloud-postgres.sh 'postgresql://user:pass@host:5432/db?sslmode=require'"
    exit 1
fi

echo ""
echo "🔗 Trying to connect using Docker ephemeral container..."
echo "   (This prevents installing psql on your host machine)"
echo ""

# Mask password for display
DISPLAY_URI=$(echo "$URI" | sed 's/:[^:@]*@/:****@/')
echo "target: $DISPLAY_URI"
echo ""

# Run connection test using alpine container
docker run --rm --network host postgres:16-alpine sh -c "
    echo '⏳ Attempting connection...'
    if psql "$URI" -c 'SELECT 1;' > /dev/null 2>&1; then
        echo '✅ CONNECTION SUCCESSFUL!'
        echo ''
        echo '📊 Server Information:'
        psql "$URI" -c 'SELECT version();'
    else
        echo '❌ CONNECTION FAILED (or Authentication Failed)'
        echo ''
        echo '🔍 Diagnostic Details:'
        # Fallback to simple query to reveal connection error without psql command issues
        psql "$URI" -c 'SELECT 1;'
    fi
"

echo ""
echo "=================================================="

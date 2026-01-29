#!/bin/bash

#===== DATABASE INITIALIZATION SCRIPT =====
# Script khởi tạo database và tạo các collection cần thiết

set -e

echo "=================================================="
echo "🗄️  Healthcare Now System - Database Initialization"
echo "=================================================="
echo ""

# Wait for MongoDB containers to be ready
echo "⏳ Waiting for MongoDB services to start..."
sleep 10

# Get MongoDB container names
CORE_DB="core_db"
IOT_DB="iot_db"
AI_DB="ai_db"
NOTIFICATION_DB="notification_db"

# Function to initialize MongoDB database
init_mongo_db() {
    local container=$1
    local db_name=$2
    
    echo "🔧 Initializing database: $db_name in container: $container"
    
    docker exec $container mongosh --eval "
        db = db.getSiblingDB('$db_name');
        
        // Create collections
        db.createCollection('users');
        db.createCollection('patients');
        db.createCollection('devices');
        db.createCollection('health_data');
        
        // Create indexes
        db.users.createIndex({ 'email': 1 }, { unique: true });
        db.patients.createIndex({ 'user_id': 1 });
        db.devices.createIndex({ 'patient_id': 1 });
        db.health_data.createIndex({ 'device_id': 1, 'timestamp': -1 });
        
        print('✓ Database $db_name initialized successfully');
    " 2>/dev/null || true
}

# Initialize Core Database
echo ""
echo "📦 Setting up Core Database..."
init_mongo_db $CORE_DB "healthcare_core"

# Initialize IoT Database
echo ""
echo "📦 Setting up IoT Database..."
init_mongo_db $IOT_DB "healthcare_iot"

# Initialize AI Database
echo ""
echo "📦 Setting up AI Database..."
if docker ps | grep -q $AI_DB; then
    init_mongo_db $AI_DB "healthcare_ai"
else
    echo "⚠️  Warning: $AI_DB container not running"
fi

# Initialize Notification Database
echo ""
echo "📦 Setting up Notification Database..."
if docker ps | grep -q $NOTIFICATION_DB; then
    init_mongo_db $NOTIFICATION_DB "healthcare_notification"
else
    echo "⚠️  Warning: $NOTIFICATION_DB container not running"
fi

# Initialize PostgreSQL
echo ""
echo "🐘 Setting up PostgreSQL Databases..."
POSTGRES_CONTAINER="postgres"
if docker ps | grep -q $POSTGRES_CONTAINER; then
    echo "⏳ Waiting for PostgreSQL to be ready..."
    sleep 5
    docker exec $POSTGRES_CONTAINER pg_isready -U postgres || true
    
    echo "🔧 Creating database and schemas..."
    # Create main database 'healthcare'
    docker exec $POSTGRES_CONTAINER psql -U postgres -c "CREATE DATABASE healthcare;" 2>/dev/null || true
    
    # Create Schemas in 'healthcare' DB
    # Note: We connect to 'healthcare' DB now
    docker exec $POSTGRES_CONTAINER psql -U postgres -d healthcare -c "CREATE SCHEMA IF NOT EXISTS auth;" 2>/dev/null || true
    docker exec $POSTGRES_CONTAINER psql -U postgres -d healthcare -c "CREATE SCHEMA IF NOT EXISTS catalog;" 2>/dev/null || true
    
    # Legacy support: Create old DBs just in case, or leave them if migration path is unclear. 
    # User requested: "1 DB -> many schema". Let's stick to schemas.
    # docker exec $POSTGRES_CONTAINER psql -U postgres -c "CREATE DATABASE healthcare_auth;" 2>/dev/null || true
    
    echo "✓ PostgreSQL initialized (DB: healthcare, Schemas: auth, catalog)"
else
     echo "⚠️  Warning: $POSTGRES_CONTAINER container not running"
fi

echo ""
echo "=================================================="
echo "✅ Database initialization completed!"
echo "=================================================="
echo ""
echo "📊 Database Summary:"
docker exec $CORE_DB mongosh --eval "
    dbs = db.getMongo().getDBNames();
    dbs.forEach(function(name) {
        if (name.includes('healthcare')) {
            print('  • [Mongo] ' + name);
        }
    });
" 2>/dev/null || true

docker exec $POSTGRES_CONTAINER psql -U postgres -c "\l" | grep "healthcare" | awk '{print "  • [Postgres DB] " $1}' 2>/dev/null || true
docker exec $POSTGRES_CONTAINER psql -U postgres -d healthcare -c "\dn" | grep -E "auth|catalog" | awk '{print "    - [Schema] " $1}' 2>/dev/null || true

echo ""

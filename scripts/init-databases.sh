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
            print('  • ' + name);
        }
    });
" 2>/dev/null || true

echo ""

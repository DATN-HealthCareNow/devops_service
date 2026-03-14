#!/bin/bash

#===== RESTORE DATABASES SCRIPT =====
# Script restore backup databases (MongoDB & PostgreSQL)

set -e

echo "=================================================="
echo "♻️  HealthCare Now System - Database Restore"
echo "=================================================="
echo ""

if [ -z "$1" ]; then
    echo "❌ Error: Please provide backup path"
    echo "Usage: ./restore-databases.sh <path_to_backup_folder>"
    echo "Example: ./restore-databases.sh ./backups/20240101_120000"
    echo ""
    echo "ℹ️  This script will attempt to restore:"
    echo "   - MongoDB collections (core, iot, ai, notification)"

    exit 1
fi

BACKUP_PATH="$1"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "❌ Error: Directory $BACKUP_PATH does not exist"
    exit 1
fi

echo "📂 Restoring from: $BACKUP_PATH"
echo ""

# Restore MongoDB
restore_mongo() {
    local container=$1
    local db_name=$2
    local archive_path="${BACKUP_PATH}/${db_name}/dump.archive"
    
    if [ -f "$archive_path" ]; then
        echo "🔄 Restoring MongoDB: $db_name..."
        cat "$archive_path" | docker exec -i $container mongorestore --archive --drop --db "$db_name" 2>/dev/null
        echo "✓ Restored $db_name"
    else
        echo "⚠️  Skipping $db_name (No backup found)"
    fi
}

echo "📦 Restoring MongoDB databases..."
restore_mongo "core_db" "healthcare_core"
restore_mongo "iot_db" "healthcare_iot"
restore_mongo "ai_db" "healthcare_ai"
restore_mongo "notification_db" "healthcare_notification"



echo ""
echo "=================================================="
echo "✅ Restore process completed!"
echo "=================================================="

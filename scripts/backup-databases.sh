#!/bin/bash

#===== BACKUP DATABASES SCRIPT =====
# Script backup tất cả MongoDB databases

set -e

echo "=================================================="
echo "💾 HealthCare Now System - Database Backup"
echo "=================================================="
echo ""

BACKUP_DIR="${HOME}/healthcare-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

# Create backup directory
mkdir -p "$BACKUP_PATH"

echo "📁 Backup directory: $BACKUP_PATH"
echo ""

# Backup each database
backup_database() {
    local container=$1
    local db_name=$2
    
    echo "🔄 Backing up $db_name from $container..."
    
    mkdir -p "${BACKUP_PATH}/${db_name}"
    
    docker exec $container mongodump \
        --db "$db_name" \
        --archive="${BACKUP_PATH}/${db_name}/dump.archive" 2>/dev/null || {
        echo "⚠️  Warning: Could not backup $db_name"
        return 1
    }
    
    echo "✓ Backup $db_name completed"
}

echo "🔄 Starting database backups..."
echo ""

backup_database "core_db" "healthcare_core"
backup_database "iot_db" "healthcare_iot"
backup_database "ai_db" "healthcare_ai"
backup_database "notification_db" "healthcare_notification"

echo ""
echo "=================================================="
echo "✅ Backup completed!"
echo "=================================================="
echo ""
echo "📊 Backup details:"
du -sh "${BACKUP_PATH}"/*

echo ""
echo "💡 To restore:"
echo "  mongorestore --archive=<backup_file> --db <database_name>"
echo ""

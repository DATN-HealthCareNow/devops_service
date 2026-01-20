#!/bin/bash

#===== VIEW LOGS SCRIPT =====
# Script xem logs của các service

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR"

if [ -z "$1" ]; then
    echo "Usage: $0 <service_name> [-f]"
    echo ""
    echo "Services:"
    docker-compose ps | awk 'NR>1 {print "  - " $1}' | sed 's/_.*$//' | sort -u
    echo ""
    echo "Options:"
    echo "  -f    Follow logs (Ctrl+C to exit)"
    echo ""
    echo "Examples:"
    echo "  $0 nginx"
    echo "  $0 prometheus -f"
    exit 1
fi

SERVICE=$1
FOLLOW=${2:-}

if [ "$FOLLOW" == "-f" ]; then
    echo "Following logs for $SERVICE (Press Ctrl+C to exit)..."
    docker-compose logs -f "$SERVICE"
else
    docker-compose logs "$SERVICE"
fi

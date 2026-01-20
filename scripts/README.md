# Automation Scripts Documentation

## Available Scripts

### 1. start-all.sh
**Khởi động toàn bộ hệ thống**

```bash
./scripts/start-all.sh
```

Các bước thực hiện:
1. Kiểm tra Docker daemon
2. Pull latest images
3. Chạy `docker-compose up -d`
4. Chờ services khởi động (10 giây)
5. Hiển thị status

### 2. stop-all.sh
**Dừng toàn bộ hệ thống**

```bash
./scripts/stop-all.sh
```

### 3. restart-all.sh
**Khởi động lại toàn bộ hệ thống**

```bash
./scripts/restart-all.sh
```

### 4. health-check.sh
**Kiểm tra trạng thái tất cả services**

```bash
./scripts/health-check.sh
```

Kiểm tra:
- Container status
- Service health endpoints
- Resource usage (CPU, Memory)

### 5. init-databases.sh
**Khởi tạo MongoDB databases**

```bash
./scripts/init-databases.sh
```

Tạo:
- Collections cần thiết
- Indexes để tối ưu query
- Default databases

### 6. view-logs.sh
**Xem logs của service**

```bash
# View logs
./scripts/view-logs.sh nginx

# Follow logs in real-time
./scripts/view-logs.sh prometheus -f
```

### 7. backup-databases.sh
**Backup tất cả MongoDB databases**

```bash
./scripts/backup-databases.sh
```

Output: `~/healthcare-backups/<timestamp>/`

Restore:
```bash
mongorestore --archive=backup_file.archive --db database_name
```

### 8. network-diagnostics.sh
**Kiểm tra network connectivity giữa containers**

```bash
./scripts/network-diagnostics.sh
```

Kiểm tra:
- Docker network status
- Container connectivity
- DNS resolution
- Active connections

---

## Setup Scripts

### Making Scripts Executable

```bash
# Linux/macOS
chmod +x scripts/*.sh

# Windows (PowerShell)
# Scripts mặc định đã executable, sử dụng bash hoặc WSL
```

### Running Scripts

```bash
# Cách 1: Direct execution (Linux/macOS)
./scripts/start-all.sh

# Cách 2: bash command
bash scripts/start-all.sh

# Cách 3: Windows PowerShell
bash.exe scripts/start-all.sh
```

---

## Advanced Usage

### Custom Environment Variables

```bash
# Trước khi chạy script, set variables
export GF_SECURITY_ADMIN_PASSWORD=mypassword
./scripts/start-all.sh
```

### Dry Run (Preview changes)

```bash
# Xem commands mà script sẽ chạy (edit script và thêm 'set -x')
bash -x scripts/start-all.sh
```

### Cron Job for Backup

```bash
# Edit crontab
crontab -e

# Thêm line này để backup hàng đêm lúc 2:00 AM
0 2 * * * /path/to/devops-service/scripts/backup-databases.sh
```

### Scheduled Health Checks

```bash
# Health check mỗi 5 phút
*/5 * * * * /path/to/devops-service/scripts/health-check.sh >> /tmp/health-check.log 2>&1
```

---

## Monitoring with Scripts

### Real-time Logs

```bash
# Follow all logs
docker-compose logs -f

# Follow specific service
./scripts/view-logs.sh nginx -f

# Last 100 lines
docker-compose logs --tail=100 nginx
```

### Performance Monitoring

```bash
# CPU & Memory usage
docker stats --no-stream

# Process information
docker exec nginx top -b -n 1

# Network statistics
docker exec nginx netstat -an
```

---

## Troubleshooting Scripts

### "Permission Denied"

```bash
chmod +x scripts/*.sh
```

### Script fails with "No such file"

```bash
# Chắc chắn chạy từ project root
cd /path/to/devops-service
./scripts/start-all.sh
```

### Docker command not found

```bash
# Kiểm tra Docker installation
docker --version
docker-compose --version

# Thêm Docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker
```

---

## Creating Custom Scripts

Template script:

```bash
#!/bin/bash

# Metadata
# Description: Do something useful
# Usage: ./scripts/my-script.sh [options]

set -e  # Exit on error

echo "=================================================="
echo "🚀 My Custom Script"
echo "=================================================="
echo ""

# Get project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR"

# Your commands here
docker-compose exec nginx nginx -t

echo ""
echo "=================================================="
echo "✅ Script completed!"
echo "=================================================="
```

Make executable:
```bash
chmod +x scripts/my-script.sh
```

---

## Best Practices

1. **Always check Docker is running first**
   ```bash
   docker ps > /dev/null || echo "Docker is not running"
   ```

2. **Use absolute paths**
   ```bash
   PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
   ```

3. **Add error handling**
   ```bash
   set -e  # Exit on error
   set -o pipefail  # Catch errors in pipes
   ```

4. **Include helpful output**
   ```bash
   echo "✓ Success"
   echo "❌ Error"
   echo "⏳ Waiting..."
   ```

---

**Maintained by DevOps Team**

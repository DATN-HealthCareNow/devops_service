# Environment Variables Configuration Guide

## 📋 File .env là gì?

File `.env` chứa tất cả các biến môi trường (environment variables) cần thiết để chạy hệ thống.

```
Status hiện tại:
✅ .env.example        - File mẫu (tôi đã tạo sẵn)
❌ .env                - File thực tế (BẠN PHẢI TỰ TẠO)
```

## 🔐 Tại sao cần phân biệt .env và .env.example?

### .env.example (Shared - Commit to Git)
- Chứa template/mẫu
- Không chứa mật khẩu thực
- Dùng để guide cộng tác viên
- Được commit vào Git

### .env (Secret - NOT Shared)
- Chứa giá trị thực tế
- **KHÔNG** commit vào Git
- **TRONG .gitignore**
- Mỗi người có file .env khác nhau

---

## ⚙️ Cách Setup .env

### Bước 1: Tạo file .env từ template
```bash
cp .env.example .env
```

### Bước 2: Mở file .env và điền giá trị thực
```bash
vi .env
# hoặc dùng editor yêu thích
```

### Bước 3: Chỉnh sửa các giá trị quan trọng

Các biến cần thay đổi:

```env
# ===== MONGODB CONFIGURATION =====
MONGO_CORE_DB=healthcare_core              # Giữ nguyên
MONGO_IOT_DB=healthcare_iot                # Giữ nguyên
MONGO_AI_DB=healthcare_ai                  # Giữ nguyên
MONGO_NOTIFICATION_DB=healthcare_notification      # Giữ nguyên

# ===== SERVICE PORTS =====
CORE_SERVICE_PORT=8081                     # Có thể thay đổi nếu port bị chiếm
IOT_SERVICE_PORT=8082
AI_SERVICE_PORT=8000
NOTIFICATION_SERVICE_PORT=8084
GATEWAY_PORT=80

# ===== GRAFANA (THAY ĐỔI CHO PRODUCTION) =====
GRAFANA_ADMIN_PASSWORD=admin              # ⚠️ THAY ĐỔI: admin → mật khẩu mạnh
# Ví dụ: GRAFANA_ADMIN_PASSWORD=GrafanaAdmin2024@

# ===== RABBITMQ (THAY ĐỔI CHO PRODUCTION) =====
RABBITMQ_USER=guest                       # ⚠️ THAY ĐỔI cho production
RABBITMQ_PASSWORD=guest                   # ⚠️ THAY ĐỔI cho production
# Ví dụ:
# RABBITMQ_USER=healthcareuser
# RABBITMQ_PASSWORD=RabbitMQ@SecurePass2024
```

---

## 🔒 Bảo mật .env

### ✅ DO (Nên làm)
```bash
# Verify .env in .gitignore
cat .gitignore | grep ".env"

# Remove from git if accidentally committed
git rm --cached .env

# Set restrictive permissions (Linux/macOS)
chmod 600 .env
```

### ❌ DON'T (Không nên làm)
```bash
# ❌ KHÔNG commit .env vào Git
git add .env
git commit -m "add env"

# ❌ KHÔNG chia sẻ .env file qua email, Slack, etc
# ❌ KHÔNG hardcode mật khẩu vào code
# ❌ KHÔNG để mật khẩu trong commit message
```

---

## 📝 Giải thích từng biến

### Database Configuration
```env
MONGO_CORE_DB=healthcare_core
# Database name cho Core Service
# Default: healthcare_core (OK để giữ nguyên)

MONGO_CORE_PORT=27017
# Port của Core Database container
# Default: 27017 (Port chuẩn MongoDB)
# Có thể thay đổi nếu port bị chiếm (e.g., 27017 → 27117)
```

### Redis Configuration
```env
REDIS_HOST=redis
# Hostname của Redis container
# Default: redis (Docker internal DNS)
# KHÔNG thay đổi nếu dùng Docker

REDIS_PORT=6379
# Port của Redis
# Default: 6379 (Port chuẩn Redis)
```

### RabbitMQ Configuration
```env
RABBITMQ_HOST=rabbitmq
# Hostname của RabbitMQ container
# Default: rabbitmq

RABBITMQ_USER=guest
# Username để đăng nhập RabbitMQ
# Default: guest
# ⚠️ THAY ĐỔI CHO PRODUCTION

RABBITMQ_PASSWORD=guest
# Password để đăng nhập RabbitMQ
# Default: guest
# ⚠️ THAY ĐỔI CHO PRODUCTION
# Ví dụ password mạnh: P@ssw0rd!123456
```

### Service Ports
```env
CORE_SERVICE_PORT=8081
# Port của Core Service
# Ví dụ: localhost:8081/api/v1/auth
# Có thể thay nếu 8081 bị chiếm

IOT_SERVICE_PORT=8082
# Port của IoT Service

AI_SERVICE_PORT=8000
# Port của AI Service
```

### Grafana Configuration
```env
GRAFANA_ADMIN_PASSWORD=admin
# Mật khẩu admin của Grafana
# Default: admin
# ⚠️ ĐỔI THÀNH CHẮC CHẮn CHO PRODUCTION
# Quy tắc: 
#   - Tối thiểu 8 ký tự
#   - Có chữ hoa, chữ thường, số, ký tự đặc biệt
# Ví dụ: GrafanaProd@2024!

GRAFANA_PORT=3000
# Port của Grafana dashboard
# Default: 3000
# Access: http://localhost:3000/grafana
```

### Prometheus Configuration
```env
PROMETHEUS_PORT=9090
# Port của Prometheus
# Default: 9090
# Access: http://localhost:9090
```

### Java Options
```env
JAVA_OPTS=-Xmx512m -Xms256m
# JVM memory settings cho Java services
# -Xms256m = Initial heap size 256 MB
# -Xmx512m = Maximum heap size 512 MB
# Tăng lên nếu service out of memory
# Ví dụ: JAVA_OPTS=-Xmx2g -Xms1g (cho 2GB heap)
```

---

## 💡 Ví dụ .env Configuration cho Development

```env
# ===== MONGODB CONFIGURATION =====
MONGO_CORE_DB=healthcare_core
MONGO_IOT_DB=healthcare_iot
MONGO_AI_DB=healthcare_ai
MONGO_NOTIFICATION_DB=healthcare_notification

MONGO_CORE_PORT=27017
MONGO_IOT_PORT=27018
MONGO_AI_PORT=27019
MONGO_NOTIFICATION_PORT=27020

# ===== REDIS CONFIGURATION =====
REDIS_HOST=redis
REDIS_PORT=6379

# ===== RABBITMQ CONFIGURATION =====
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
RABBITMQ_VHOST=/

# ===== SERVICE CONFIGURATION =====
CORE_SERVICE_PORT=8081
IOT_SERVICE_PORT=8082
AI_SERVICE_PORT=8000
NOTIFICATION_SERVICE_PORT=8084
GATEWAY_PORT=80

# ===== NGINX CONFIGURATION =====
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

# ===== GRAFANA CONFIGURATION =====
GRAFANA_ADMIN_PASSWORD=admin
GRAFANA_PORT=3000

# ===== PROMETHEUS CONFIGURATION =====
PROMETHEUS_PORT=9090

# ===== JAVA OPTIONS =====
JAVA_OPTS=-Xmx512m -Xms256m
```

## 💡 Ví dụ .env Configuration cho Production

```env
# ===== MONGODB CONFIGURATION =====
MONGO_CORE_DB=healthcare_core
MONGO_IOT_DB=healthcare_iot
MONGO_AI_DB=healthcare_ai
MONGO_NOTIFICATION_DB=healthcare_notification

# MongoDB ports (changed from defaults for security)
MONGO_CORE_PORT=27017
MONGO_IOT_PORT=27018
MONGO_ANALYSIS_PORT=27019
MONGO_TRACKING_PORT=27020

# ===== REDIS CONFIGURATION =====
REDIS_HOST=redis
REDIS_PORT=6379
# Add password for production
# REDIS_PASSWORD=Redis@SecurePass2024

# ===== RABBITMQ CONFIGURATION =====
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672
RABBITMQ_USER=healthcareuser
RABBITMQ_PASSWORD=RabbitMQ@SecurePass2024
RABBITMQ_VHOST=/healthcareprod

# ===== SERVICE CONFIGURATION =====
CORE_SERVICE_PORT=8081
IOT_SERVICE_PORT=8082
AI_SERVICE_PORT=8000
NOTIFICATION_SERVICE_PORT=8084
GATEWAY_PORT=80

# ===== NGINX CONFIGURATION =====
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

# ===== GRAFANA CONFIGURATION =====
GRAFANA_ADMIN_PASSWORD=GrafanaAdmin@2024!
GRAFANA_PORT=3000

# ===== PROMETHEUS CONFIGURATION =====
PROMETHEUS_PORT=9090

# ===== JAVA OPTIONS (Higher for production) =====
JAVA_OPTS=-Xmx2g -Xms1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

---

## 🚀 Verify .env Setup

Sau khi tạo .env, chạy lệnh này để verify:

```bash
# Kiểm tra .env tồn tại
ls -la .env

# Kiểm tra nội dung
cat .env

# Kiểm tra .env in .gitignore
grep ".env" .gitignore

# Kiểm tra .env KHÔNG commit to git
git status | grep .env

# Kiểm tra container có nhận .env không
docker-compose config | grep GRAFANA_ADMIN_PASSWORD
```

---

## ❌ Lỗi Thường Gặp

### ❌ Error: ".env file not found"
```bash
# Solution:
cp .env.example .env
```

### ❌ Error: "Grafana access denied"
```bash
# Kiểm tra mật khẩu trong .env
cat .env | grep GRAFANA_ADMIN_PASSWORD

# Nếu sai, reset Grafana
docker-compose restart grafana
```

### ❌ Error: "RabbitMQ authentication failed"
```bash
# Kiểm tra credentials
cat .env | grep RABBITMQ

# Must match: RABBITMQ_USER=xxx, RABBITMQ_PASSWORD=yyy
docker-compose logs rabbitmq
```

### ❌ Error: "Port already in use"
```bash
# Solution: Thay đổi port trong .env
# Ví dụ: NGINX_HTTP_PORT=80 → NGINX_HTTP_PORT=8080

# Kiểm tra port nào bị dùng
lsof -i :80    # macOS/Linux
netstat -ano | findstr :80  # Windows
```

---

## 📋 Checklist Setup .env

- [ ] Có file .env (từ `cp .env.example .env`)
- [ ] Chỉnh sửa GRAFANA_ADMIN_PASSWORD thành mật khẩu mạnh
- [ ] Chỉnh sửa RABBITMQ_USER & PASSWORD cho production
- [ ] .env trong .gitignore
- [ ] .env KHÔNG commit vào git
- [ ] Verify với `docker-compose config`
- [ ] Test login Grafana http://localhost:3000/grafana

---

## 🔗 Reference

- [Docker Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [12 Factor App - Config](https://12factor.net/config)
- [RabbitMQ Default User](https://www.rabbitmq.com/access-control.html)

---

**Key Takeaway:**
- `.env.example` là template, commit vào Git
- `.env` là secret, KHÔNG commit vào Git
- Mỗi team member có .env khác nhau
- Production .env phải có mật khẩu mạnh

✅ **Setup .env Now!**

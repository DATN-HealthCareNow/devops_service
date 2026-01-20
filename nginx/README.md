# Nginx Configuration Documentation

## Cấu trúc file

```
nginx/
├── Dockerfile              # Build image
├── conf.d/
│   └── app.conf           # Main application routing
└── html/
    └── index.html         # Health check page
```

## Routing Rules

### Core Service Routes (8081)
- `/api/v1/auth` → Authentication & Authorization
- `/api/v1/user` → User Management
- `/api/v1/patient` → Patient Management

### IoT Service Routes (8082)
- `/api/v1/tracking` → Device Tracking
- `/api/v1/device` → Device Management
- `/api/v1/sensor` → Sensor Data

### AI Service Routes (8000)
- `/api/v1/analysis` → AI Analysis
- `/api/v1/predict` → Predictions
- `/api/v1/report` → Reports Generation

### Notification Service Routes (8084)
- `/api/v1/notify` → Send notifications
- `/api/v1/alerts` → Alert stream
- `/api/v1/reminders` → Reminders/scheduled notices

### Monitoring & Health
- `/grafana/` → Grafana Dashboard
- `/health` → Health Check

## Cấu hình SSL/TLS (Production)

Uncomment SSL block trong app.conf:

```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}
```

## Performance Tuning

### Buffer Size
```nginx
proxy_buffer_size 128k;
proxy_buffers 4 256k;
```

### Timeout
```nginx
proxy_connect_timeout 120s;
proxy_send_timeout 300s;
proxy_read_timeout 300s;
```

### Connection Pooling
```nginx
upstream core_service {
    least_conn;
    server core-service:8081 weight=1;
    server core-service:8081 weight=1;
    keepalive 32;
}
```

## Debugging

```bash
# Kiểm tra syntax
docker exec nginx nginx -t

# Reload config
docker exec nginx nginx -s reload

# View logs
docker-compose logs -f nginx

# Check connections
docker exec nginx netstat -an
```

## Load Balancing

Để enable load balancing:

```nginx
upstream core_service {
    server core-service-1:8081;
    server core-service-2:8081;
}
```

## Rate Limiting

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;

location ~ ^/api/ {
    limit_req zone=api_limit burst=200 nodelay;
}
```

## Caching

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=1g inactive=60m use_temp_path=off;

location ~ ^/api/v1/patient {
    proxy_cache api_cache;
    proxy_cache_key "$scheme$request_method$host$request_uri";
    proxy_cache_valid 200 10m;
    add_header X-Cache-Status $upstream_cache_status;
}
```

---

**Maintained by DevOps Team**

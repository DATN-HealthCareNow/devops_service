# Monitoring Setup Documentation

## Prometheus Configuration

Prometheus thu thập metrics từ các service thông qua HTTP requests. Mỗi service phải expose một endpoint cho Prometheus.

### Supported Services

> Lưu ý: Trong cùng Docker network, luôn dùng service name thay vì localhost để tránh sai đích.

```yaml
- Job Name: prometheus (Prometheus itself)
  Target: prometheus:9090
  Endpoint: /metrics
  
- Job Name: core-service
  Target: core-service:8081
  Endpoint: /actuator/prometheus (Spring Boot)
  
- Job Name: iot-service
  Target: iot-service:8082
  Endpoint: /actuator/prometheus (Spring Boot)
  
- Job Name: ai-service
  Target: ai-service:8000
  Endpoint: /metrics (FastAPI + prometheus-fastapi-instrumentator)
  
- Job Name: notification-service
  Target: notification-service:8084
  Endpoint: /actuator/prometheus (Spring Boot)
```

### Scrape Intervals

- **Global**: 15 seconds (mặc định)
- **Prometheus**: 5 seconds (nhanh hơn để monitoring Prometheus itself)
- **Services**: 15 seconds (balance giữa accuracy và resource)

### Data Retention

- Default: 30 days
- Có thể thay đổi qua flag: `--storage.tsdb.retention.time=90d`

---

## Grafana Setup

### Access
- URL: http://localhost:3000/grafana
- Username: admin
- Password: admin

### Adding Datasource

1. Mở Grafana → Configuration → Datasources
2. Click "Add data source"
3. Select "Prometheus"
4. URL: http://prometheus:9090
5. Click "Save & Test"

### Creating Dashboards

#### Option 1: Import Pre-built Dashboards
1. Grafana → Dashboards → Import
2. Ưu tiên: ID 4701 (Spring Boot) hoặc ID 11377 (JVM chi tiết)
3. (Tùy chọn) ID 1860 (Node Exporter Full) cho host-level metrics
4. Click "Load"

#### Option 2: Build Custom Dashboard
1. Grafana → Dashboards → New
2. Add panels từ queries
3. Query examples:
   ```
   up{job="core-service"}  # Service availability
   rate(http_requests_total[5m])  # Request rate
   process_resident_memory_bytes  # Memory usage
   process_cpu_seconds_total  # CPU time
   ```

### Key Metrics to Monitor

```
# Application Metrics
http_requests_total  # Tổng requests
http_request_duration_seconds  # Request latency
http_requests_in_progress  # Concurrent requests

# JVM Metrics (Java Services)
jvm_memory_used_bytes  # Heap memory usage
jvm_gc_duration_seconds  # GC pause time
jvm_threads_live  # Active threads

# System Metrics
process_cpu_seconds_total  # CPU time
process_resident_memory_bytes  # Memory usage
process_open_fds  # Open file descriptors
```

---

## Spring Boot Integration

Bạn BE cần thêm Micrometer vào spring-boot-starter-actuator.

### pom.xml
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

### application.yml
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,prometheus,info,metrics
  metrics:
    export:
      prometheus:
        enabled: true
  endpoint:
    prometheus:
      enabled: true
```

---

## Alerting (Optional)

### Cấu hình Alertmanager

```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093
```

### Alert Rules Example

```yaml
groups:
  - name: healthcare
    interval: 30s
    rules:
      - alert: ServiceDown
        expr: up{job=~"core-service|iot-service|ai-service"} == 0
        for: 2m
        annotations:
          summary: "Service {{ $labels.job }} is down"

      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes > 1e9
        for: 5m
        annotations:
          summary: "High memory usage on {{ $labels.container_name }}"
```

---

## Performance Optimization

### Thresholds
- **Scrape Interval**: 15s (balance giữa accuracy và overhead)
- **Evaluation Interval**: 15s
- **Retention Time**: 30 days (có thể tăng tùy storage)

### Storage Management

```bash
# Kiểm tra size
du -sh /prometheus

# Cleanup old data (manual)
docker exec prometheus \
  prometheus admin tsdb clean-tombstones
```

### Backup Prometheus Data

```bash
# Manual backup
docker exec prometheus tar czf - /prometheus | \
  gzip > prometheus_backup_$(date +%s).tar.gz

# Restore
docker exec prometheus tar xzf prometheus_backup_*.tar.gz -C /
```

---

## Troubleshooting

### Targets không show UP

```bash
# Check logs
docker-compose logs prometheus

# Verify endpoint
curl http://core-service:8081/actuator/prometheus

# Check network
docker exec prometheus ping core-service
```

### Metrics not appearing

```bash
# Xem query history
curl http://localhost:9090/api/v1/query_range
```

### Disk space full

```bash
# Check size
docker exec prometheus du -sh /prometheus

# Reduce retention
# Thêm flag: --storage.tsdb.retention.time=7d
```

---

## Custom Metrics (Java Applications)

```java
import io.micrometer.core.instrument.MeterRegistry;

@Component
public class CustomMetrics {
    public CustomMetrics(MeterRegistry registry) {
        // Counter: Số lần được gọi
        registry.counter("patient.created.total").increment();
        
        // Gauge: Giá trị hiện tại
        registry.gauge("patient.count.active", 
            () -> patientService.getActiveCount());
        
        // Timer: Đo thời gian
        registry.timer("api.response.time", 
            "endpoint", "/api/v1/patient")
            .record(() -> businessLogic());
    }
}
```

Gợi ý metric thực tế cho dự án:
- `sos.alert.total`: Tổng số lần phát hiện té ngã
- `ai.analysis.latency`: Thời gian AI xử lý một tấm hình
- `water.goal.reached.users`: Số người dùng hoàn thành mục tiêu uống nước trong ngày

## Hướng dẫn nhanh cho BE

"Ông ơi, trong các repo Backend Java, ông nhớ thêm 2 dependency Actuator và Micrometer Prometheus vào pom.xml. Sau đó vào application.yml mở port cho nó như trong file monitoring/readme.md tôi vừa viết nhé. Riêng cái ai-service (Python), ông cài thêm prometheus-fastapi-instrumentator để tôi kéo metrics về Grafana vẽ biểu đồ nộp thầy cô."

---

**Maintained by DevOps Team**

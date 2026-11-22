# Infrastructure Monitoring with Prometheus & Grafana

## Components
- Prometheus (9090): scrapes and stores metrics
- Grafana (3000): dashboards
- Alertmanager (9093): sends email alerts
- Node Exporter (9100): system metrics
- cAdvisor (8081): container metrics
- Flask app (8080): application metrics at /metrics

## Run
1. Copy alertmanager/alertmanager.yml.example to alertmanager/alertmanager.yml and add your email and Gmail App Password.
2. docker compose up -d
3. Open Grafana at localhost:3000 and add Prometheus as a data source (http://prometheus:9090).
4. Import grafana/infra-dashboard.json.

## Alerts
ServiceDown, HighCPUUsage, HighMemoryUsage, LowDiskSpace, ContainerHighCPU

## Tests performed
Stopped flask-app and node-exporter, ran a CPU load container, confirmed alerts fired and emails were received.

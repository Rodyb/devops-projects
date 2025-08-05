
# Flask App Monitoring with Prometheus, Grafana, and Alertmanager

This project sets up a complete monitoring stack for a Flask application, integrated with Prometheus, Grafana, and Alertmanager. The setup tracks metrics, visualizes them, and sends alerts when thresholds are breached.

## Tools Used

- **Flask**: Python web framework hosting the application.
- **Prometheus**: Collects and stores metrics from the Flask app.
- **Grafana**: Visualizes metrics from Prometheus and creates dashboards.
- **Alertmanager**: Sends alerts when Prometheus detects abnormal conditions.
- **Docker Compose**: Orchestrates the entire stack.

---

## Monitoring Overview

### Metrics Collected
- **Request Count**: Tracks total requests to the Flask app.
- **Request Latency**: Monitors response times for each endpoint.
- **Custom Metrics**: Any additional application-specific metrics.

### Alerts Configured
- **High Request Volume**: Alerts when total requests exceed 500 for more than 10 seconds.
- **Instance Down**: Alerts if the Flask app or Prometheus becomes unreachable.

---

## Steps in the Monitoring Setup

### Flask Application
The Flask app is instrumented with Prometheus metrics using the `prometheus_client` library. Metrics are exposed at the `/metrics` endpoint.

```python
# Example metrics
REQUEST_COUNT = Counter('flask_app_requests_total', 'Total number of requests', ['method', 'endpoint', 'http_status'])
REQUEST_LATENCY = Histogram('flask_app_request_latency_seconds', 'Request latency in seconds', ['endpoint'])
```

### Prometheus Configuration
Prometheus scrapes metrics from the Flask app and evaluates alerting rules. The `prometheus.yml` configuration includes the Flask app and Alertmanager:

```yaml
scrape_configs:
  - job_name: 'flask-app'
    static_configs:
      - targets: ['flask-app:5000']

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

### Grafana Dashboard
Grafana visualizes Flask metrics using PromQL queries, such as:
- Total Requests: `flask_app_requests_total`
- Latency: `histogram_quantile(0.95, rate(flask_app_request_latency_seconds_bucket[1m]))`

### Alertmanager
Alertmanager is configured to send email alerts when Prometheus detects specific conditions. Example alert:

```yaml
- alert: HighRequestVolume
  expr: flask_app_requests_total > 500
  for: 10s
  labels:
    severity: critical
  annotations:
    summary: "High Request Volume Detected"
    description: "Total requests exceeded 500 for 10 seconds."
```

---

## Key Features

- **Real-Time Monitoring**: Tracks requests, latency, and custom metrics.
- **Alerts**: Sends email alerts for high request volume and service outages.
- **Visualization**: Dashboards for easy metric analysis in Grafana.
- **Dockerized Setup**: All services run seamlessly using Docker Compose.

---

## Project Structure

```plaintext
.
├── app.py                     # Flask application source code
├── Dockerfile                 # Dockerfile for building the Flask app
├── docker-compose.yml         # Docker Compose configuration for the stack
├── prometheus/
│   └── prometheus.yml         # Prometheus configuration
├── alertmanager/
│   └── alertmanager.yml       # Alertmanager configuration
├── k6/
│   └── loadtest.js            # K6 load test script to generate traffic
└── README.md                  # Project documentation
```

---

## How to Run

1. **Start the Monitoring Stack and run the tests**:
   ```bash
   docker-compose up --build
   ```

2. **Access the Services**:
    - Flask App: [http://localhost:5002](http://localhost:5002)
    - Prometheus: [http://localhost:9090](http://localhost:9090)
    - Grafana: [http://localhost:3000](http://localhost:3000)
    - Alertmanager: [http://localhost:9093](http://localhost:9093)

3. **View Metrics and Alerts**:
    - Grafana dashboards will visualize metrics.
    - Email alerts will trigger if thresholds are breached.

---

## Alerts Example

### High Request Volume Alert
- **Condition**: Total requests > 500 for 10 seconds.
- **Action**: Sends an email alert.

### Instance Down Alert
- **Condition**: Flask app or Prometheus becomes unreachable.
- **Action**: Sends an email alert.



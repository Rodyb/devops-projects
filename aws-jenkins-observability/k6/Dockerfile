FROM grafana/k6:latest

WORKDIR /k6

COPY test_api.js .

ENTRYPOINT ["k6", "run", "test_api.js"]



#!/bin/bash

SERVER_IP="$1"
TIMEOUT=${2:-300}
INTERVAL=${3:-5}

START_TIME=$(date +%s)
echo "Polling server $SERVER_IP for port 22 availability..."

while true; do
    # Check if port 22 is open
    nc -z -w 3 "$SERVER_IP" 22 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Port 22 is open on $SERVER_IP. Server is ready."
        exit 0
    else
        echo "Port 22 is not open on $SERVER_IP. Retrying..."
    fi

    # Check if the timeout has been reached
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
    if [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; then
        echo "Timeout reached. Server $SERVER_IP is not ready after $TIMEOUT seconds."
        exit 1
    fi

    sleep "$INTERVAL"
done

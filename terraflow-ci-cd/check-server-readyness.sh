#!/bin/bash

# Variables
SERVER_IP="$1"
TIMEOUT=${2:-300}  # Default timeout is 300 seconds
INTERVAL=${3:-5}   # Check every 5 seconds by default

# Start time
START_TIME=$(date +%s)

echo "Checking if server $SERVER_IP is ready on port 22..."

while true; do
    # Attempt to connect to port 22
    nc -z -w 3 "$SERVER_IP" 22 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Server $SERVER_IP is ready on port 22."
        exit 0
    fi

    # Check if the timeout has been reached
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

    if [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; then
        echo "Timeout reached. Server $SERVER_IP is not ready on port 22 after $TIMEOUT seconds."
        exit 1
    fi

    # Wait before retrying
    sleep "$INTERVAL"
done

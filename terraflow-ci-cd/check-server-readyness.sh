#!/bin/bash

# Variables
SERVER_IP="$1"
TIMEOUT=${2:-300}  # Default timeout is 300 seconds
INTERVAL=${3:-5}   # Check every 5 seconds by default

# Ensure SSH_AUTH_SOCK is set
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Error: SSH agent not available. Ensure ssh-agent is running and keys are loaded."
    exit 1
fi

# Start time
START_TIME=$(date +%s)

echo "Polling server $SERVER_IP for SSH readiness..."

while true; do
    # Check if port 22 is open
    nc -z -w 3 "$SERVER_IP" 22 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Port 22 is open on $SERVER_IP. Verifying SSH connection..."

        # Try SSH connection using ssh-agent
        ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@"$SERVER_IP" exit
        if [ $? -eq 0 ]; then
            echo "SSH connection successful to $SERVER_IP. Server is ready."
            exit 0
        else
            echo "Port 22 open but SSH connection failed. Retrying..."
        fi
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

    # Wait before retrying
    sleep "$INTERVAL"
done

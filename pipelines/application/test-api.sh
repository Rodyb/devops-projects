#!/bin/bash

# Test script for Message Board API
# Usage: ./test-api.sh [base_url]
# Default base_url: http://localhost:5000

BASE_URL=${1:-http://localhost:5000}

echo "Testing Message Board API at: ${BASE_URL}"
echo ""

# Test Health Endpoint
echo "1. Testing health endpoint..."
curl -X GET "${BASE_URL}/api/health" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n\n"

# Test Create Message
echo "2. Creating a test message..."
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "content": "This is a test message created via curl"
  }' \
  -w "\nHTTP Status: %{http_code}")

echo "$RESPONSE"
echo ""

# Extract message ID from response (if successful)
MESSAGE_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -n "$MESSAGE_ID" ]; then
  echo "Message created with ID: $MESSAGE_ID"
  echo ""
  
  # Test Get All Messages
  echo "3. Getting all messages..."
  curl -X GET "${BASE_URL}/api/messages" \
    -H "Content-Type: application/json" \
    -w "\nHTTP Status: %{http_code}\n\n"
  
  # Test Get Message by ID
  echo "4. Getting message by ID: $MESSAGE_ID"
  curl -X GET "${BASE_URL}/api/messages/${MESSAGE_ID}" \
    -H "Content-Type: application/json" \
    -w "\nHTTP Status: %{http_code}\n\n"
else
  echo "Failed to create message. Please check the response above."
fi


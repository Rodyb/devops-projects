# Curl Test Commands for Message Board API

## Quick Test - Create a Message

```bash
curl -X POST http://localhost:5000/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "content": "This is a test message created via curl"
  }'
```

## All API Endpoints

### 1. Health Check
```bash
curl -X GET http://localhost:5000/api/health
```

### 2. Create Message
```bash
curl -X POST http://localhost:5000/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Your Name",
    "content": "Your message content here"
  }'
```

### 3. Get All Messages
```bash
curl -X GET http://localhost:5000/api/messages
```

### 4. Get Message by ID
```bash
curl -X GET http://localhost:5000/api/messages/1
```
(Replace `1` with the actual message ID)

### 5. Update Message
```bash
curl -X PUT http://localhost:5000/api/messages/1 \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Updated message content"
  }'
```

### 6. Delete Message
```bash
curl -X DELETE http://localhost:5000/api/messages/1
```

## Using the Test Script

A test script is provided at `test-api.sh`. Run it with:

```bash
./test-api.sh
```

Or specify a different base URL:

```bash
./test-api.sh http://localhost:5100
```

## Expected Response for Create Message

Successful creation (HTTP 201):
```json
{
  "id": 1,
  "name": "Test User",
  "content": "This is a test message created via curl",
  "createdAt": "2024-01-01T12:00:00.000Z",
  "updatedAt": "2024-01-01T12:00:00.000Z"
}
```

Error response (HTTP 400) - Validation failed:
```json
{
  "error": "Validation failed",
  "message": "Name is required"
}
```


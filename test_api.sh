#!/bin/bash

echo "Testing EmotionVisualizer API..."
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s http://localhost:8000/health | python3 -m json.tool
echo ""

# Test registration
echo "2. Testing user registration..."
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"demo@example.com\",\"password\":\"Demo123!\",\"name\":\"Demo User\"}" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['access_token'])")

echo "Token: ${TOKEN:0:50}..."
echo ""

# Test creating an entry
echo "3. Testing emotion entry creation..."
curl -s -X POST http://localhost:8000/api/v1/entries \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"situation":"Feeling great today!","emotions":["joy","excitement"],"intensity":0.8}' \
  | python3 -m json.tool
echo ""

# Test listing entries
echo "4. Testing list entries..."
curl -s -X GET http://localhost:8000/api/v1/entries \
  -H "Authorization: Bearer $TOKEN" \
  | python3 -m json.tool
echo ""

echo "✅ All tests completed!"

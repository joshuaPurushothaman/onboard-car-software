#!/bin/bash
set -e

# Start Kafka Connect in the background
/etc/confluent/docker/run &
KAFKA_PID=$!

# Forward SIGTERM to Kafka Connect for clean shutdown
trap "echo 'Received SIGTERM, shutting down Kafka Connect...'; kill -TERM $KAFKA_PID; wait $KAFKA_PID; exit 0" SIGTERM SIGINT

# Wait for Kafka Connect REST API to be fully ready
echo "Waiting for Kafka Connect REST API to be ready..."
until curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/connectors | grep -q "200"; do
  echo "Kafka Connect not ready yet, waiting..."
  sleep 1
done
echo "Kafka Connect is ready!"

# Create Redis connector if it doesn't exist
if curl -s -f http://localhost:8083/connectors/redis-testytime-source > /dev/null 2>&1; then
  echo "Connector already exists, skipping creation."
else
  echo "Creating Redis connector..."
  response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" \
       -d @"$KAFKA_CONNECTOR_DEFINITION_FILE" \
       http://localhost:8083/connectors)
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')

  if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
    echo "Connector registered successfully!"
    echo "$body"
  else
    echo "Failed to register connector. HTTP status: $http_code"
    echo "$body"
    exit 1
  fi
fi

wait $KAFKA_PID

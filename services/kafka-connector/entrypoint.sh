#!/bin/bash
set -e

# Validate required environment variables
required_vars=("DEVICE_NAME" "CONNECT_BOOTSTRAP_SERVERS" "CONNECT_REST_ADVERTISED_HOST_NAME")
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "ERROR: Required environment variable $var is not set"
    exit 1
  fi
done

# Compute Kafka Connect configuration from DEVICE_NAME
export CONNECT_GROUP_ID="${DEVICE_NAME}-connect"
export CONNECT_CONFIG_STORAGE_TOPIC="${DEVICE_NAME}-connect-config"
export CONNECT_OFFSET_STORAGE_TOPIC="${DEVICE_NAME}-connect-offsets"
export CONNECT_STATUS_STORAGE_TOPIC="${DEVICE_NAME}-connect-status"

echo "Configured Kafka Connect for device: ${DEVICE_NAME}"
echo "  Group ID: ${CONNECT_GROUP_ID}"
echo "  Bootstrap Servers: ${CONNECT_BOOTSTRAP_SERVERS}"
echo "  Advertised Host: ${CONNECT_REST_ADVERTISED_HOST_NAME}"

# Generate redis-connector.json from template using sed
sed "s/\${DEVICE_NAME}/${DEVICE_NAME}/g" /etc/kafka-connect/redis-connector.template.json > "$KAFKA_CONNECTOR_DEFINITION_FILE"
echo "Generated connector config from template"

# Connector name derived from DEVICE_NAME
CONNECTOR_NAME="${DEVICE_NAME}-decoded-can-source"

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
if curl -s -f "http://localhost:8083/connectors/${CONNECTOR_NAME}" > /dev/null 2>&1; then
  echo "Connector '${CONNECTOR_NAME}' already exists, skipping creation."
else
  echo "Creating Redis connector '${CONNECTOR_NAME}'..."
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

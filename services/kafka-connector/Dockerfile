FROM confluentinc/cp-kafka-connect:7.7.7

# Install Redis Kafka Connector
RUN confluent-hub install --no-prompt redis/redis-kafka-connect:0.9.1

# Add "ServiceLoader manifest" into the Redis connector JAR to avoid slow ReflectionScanner
# Faster startup
USER root
RUN mkdir -p /tmp/META-INF/services && \
    echo "com.redis.kafka.connect.RedisStreamSourceConnector" > /tmp/META-INF/services/org.apache.kafka.connect.source.SourceConnector && \
    jar -uf /usr/share/confluent-hub-components/redis-redis-kafka-connect/lib/redis-kafka-connect-0.9.1-all.jar -C /tmp META-INF && \
    rm -rf /tmp/META-INF
USER appuser


# Environment variables for Kafka Connect configuration
ENV KAFKA_CONNECTOR_DEFINITION_FILE=/etc/kafka-connect/redis-connector.json \
    CONNECT_PLUGIN_PATH=/usr/share/confluent-hub-components \
    CONNECT_BOOTSTRAP_SERVERS="clean-kafka.jacob-smoot.ts.net:9092" \
    CONNECT_GROUP_ID="car-redis" \
    CONNECT_REST_ADVERTISED_HOST_NAME="andrew-laptop.jacob-smoot.ts.net" \
    CONNECT_CONFIG_STORAGE_TOPIC="car-redis-config" \
    CONNECT_OFFSET_STORAGE_TOPIC="car-redis-offsets" \
    CONNECT_STATUS_STORAGE_TOPIC="car-redis-status" \
    CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 \
    CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 \
    CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 \
    CONNECT_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
    CONNECT_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
    CONNECT_PLUGIN_DISCOVERY="service_load" \
    KAFKA_HEAP_OPTS="-Xms256M -Xmx1G"
    # Cap JVM memory use at 1GB


# Copy entrypoint files and run
COPY entrypoint.sh /entrypoint.sh
COPY redis-connector.json /etc/kafka-connect/redis-connector.json

ENTRYPOINT ["/entrypoint.sh"]
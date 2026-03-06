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
# DEVICE_NAME, CONNECT_BOOTSTRAP_SERVERS, and CONNECT_REST_ADVERTISED_HOST_NAME
# must be provided at runtime. Other CONNECT_* vars are computed in entrypoint.sh
ENV KAFKA_CONNECTOR_DEFINITION_FILE=/etc/kafka-connect/redis-connector.json \
    CONNECT_PLUGIN_PATH=/usr/share/confluent-hub-components \
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
COPY redis-connector.template.json /etc/kafka-connect/redis-connector.template.json

ENTRYPOINT ["/entrypoint.sh"]
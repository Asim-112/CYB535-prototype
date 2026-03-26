#!/bin/bash
# Creates three Java environment containers to simulate different build/test/analysis environments.
#
# java17-builder  - Used for compiling the application (Build stage)
# java11-tester   - Used for running unit tests (Test stage)
# java8-analyzer  - Used for SonarQube analysis (Analysis stage)

NETWORK_NAME="cicd-network"

declare -A CONTAINERS=(
    ["java17-builder"]="openjdk:17"
    ["java11-tester"]="openjdk:11"
    ["java8-analyzer"]="openjdk:8"
)

for NAME in "${!CONTAINERS[@]}"; do
    IMAGE="${CONTAINERS[$NAME]}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
        echo "Container '$NAME' already exists. Skipping."
    else
        echo "Starting $NAME ($IMAGE)..."
        docker run -dit \
            --name "$NAME" \
            --network "$NETWORK_NAME" \
            "$IMAGE"
    fi
done

echo ""
echo "Verification:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | grep -E "java|NAMES"

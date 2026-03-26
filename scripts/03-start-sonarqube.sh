#!/bin/bash
# Starts SonarQube in a Docker container for static code analysis.
#
# Port 9000 - SonarQube dashboard
# Accessible from Jenkins as http://sonarqube:9000 (via Docker network DNS)

CONTAINER_NAME="sonarqube"
NETWORK_NAME="cicd-network"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '$CONTAINER_NAME' already exists."
    echo "To restart: docker start $CONTAINER_NAME"
    echo "To remove and recreate: docker rm -f $CONTAINER_NAME"
    exit 0
fi

docker pull sonarqube

docker run -d \
    --name "$CONTAINER_NAME" \
    --network "$NETWORK_NAME" \
    -p 9000:9000 \
    sonarqube

echo ""
echo "SonarQube is starting (may take 1-2 minutes)..."
echo "Dashboard: http://localhost:9000"
echo "Default login: admin / admin"
echo ""
echo "After login, generate a token:"
echo "  My Account -> Security -> Generate Token"
echo "  Save this token for Jenkins configuration."

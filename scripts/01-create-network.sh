#!/bin/bash
# Creates a custom Docker bridge network for CI/CD services.
# All containers (Jenkins, SonarQube, Java builders) attach to this network
# so they can discover each other by container name (DNS resolution).

NETWORK_NAME="cicd-network"

if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Network '$NETWORK_NAME' already exists."
else
    docker network create "$NETWORK_NAME"
    echo "Network '$NETWORK_NAME' created."
fi

echo ""
echo "Verification:"
docker network ls | grep "$NETWORK_NAME"

#!/bin/bash
set -e

PROJECT_DIR=~/Documents/JavaSpringBoot_App
DOCKER_USER="zwelakhem"
IMAGE_NAME="$DOCKER_USER/javaspringboot_app"
TAG="1.0"

cd "$PROJECT_DIR"

echo "📦 1. Building Java app with Maven..."
mvn clean package

echo "🐳 2. Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

echo "📡 3. Logging into Docker Hub..."
docker login -u $DOCKER_USER

echo "📤 4. Pushing Docker image to Docker Hub..."
docker push $IMAGE_NAME:$TAG
docker tag $IMAGE_NAME:$TAG $IMAGE_NAME:latest
docker push $IMAGE_NAME:latest

echo "🏃 5. Running container locally..."
docker stop javaspringboot_app || true
docker rm javaspringboot_app || true
docker run -d --name javaspringboot_app -p 8080:8080 $IMAGE_NAME:$TAG

echo "🌐 6. Testing LiveScore API..."
sleep 5
curl -s http://localhost:8080/score | jq

echo "✅ Demo complete! Visit http://localhost:8080/score in browser."


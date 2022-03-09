#!/bin/bash

docker run --rm --network=$DOCKER_NETWORK --name=$PROJECT_NAME-redis -d redis

REDIS_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $PROJECT_NAME-redis)

docker buildx build $DOCKER_ARGS \
    --build-arg MAINTENANCE_REDIS_HOST=$REDIS_IP \
    --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
    --build-arg DD_API_KEY=$DD_API_KEY \
    .
rc=$?

docker stop $PROJECT_NAME-redis

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi

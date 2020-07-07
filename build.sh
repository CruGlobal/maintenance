#!/bin/bash

docker network create $PROJECT_NAME
docker run --rm --network=$PROJECT_NAME --name=$PROJECT_NAME-redis -d redis

docker build \
    --network $PROJECT_NAME \
    --build-arg MAINTENANCE_REDIS_HOST=$PROJECT_NAME-redis \
    --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
    --build-arg DD_API_KEY=$DD_API_KEY \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$ENVIRONMENT-$BUILD_NUMBER .
rc=$?

docker stop $PROJECT_NAME-redis
docker network rm $PROJECT_NAME

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi

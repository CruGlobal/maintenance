#!/bin/bash

docker network create $PROJECT_NAME
docker run --rm --network=$PROJECT_NAME --name=$PROJECT_NAME-redis -d redis

docker build \
    --network $PROJECT_NAME \
    --build-arg REDIS_PORT_6379_TCP_ADDR=$PROJECT_NAME-redis \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$GIT_COMMIT-$BUILD_NUMBER .
rc=$?

docker stop $PROJECT_NAME-redis
docker network rm $PROJECT_NAME

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi

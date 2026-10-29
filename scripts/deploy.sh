#!/bin/bash
set -e
NAME=flask-app
# remember the running version so we can roll back
docker inspect -f '{{.Config.Image}}' $NAME > ~/.prev_image 2>/dev/null || true
docker pull "$IMAGE:$TAG"
docker rm -f $NAME 2>/dev/null || true
docker run -d --name $NAME --restart unless-stopped -p 8080:8080 "$IMAGE:$TAG"
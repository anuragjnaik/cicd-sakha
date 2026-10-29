#!/bin/bash
PREV=$(cat ~/.prev_image 2>/dev/null || true)
docker rm -f flask-app 2>/dev/null || true
if [ -n "$PREV" ]; then
  docker run -d --name flask-app --restart unless-stopped -p 8080:8080 "$PREV"
  echo "Rolled back to $PREV"
else
  echo "No previous version to roll back to"
fi
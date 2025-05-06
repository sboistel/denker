#!/usr/bin/env bash

# VARS
time=$(date +%Y-%m-%d)
pub_ip=$(curl -s --max-time 2 ifconfig.me || echo "Uknown IP")
img_path="/opt/denker/capture"

# Check if Docker image exists
docker_sender_exists=$(docker image ls | grep "docker_sender")
if [ ! -n "$docker_sender_exists" ]; then
  docker build -t docker_sender /opt/denker/
fi

# Watch for authentication failures
journalctl -f | while read -r line; do
  if echo "$line" | grep -q "pam_unix(gdm-password:auth): authentication failure"; then

    fswebcam -r 640x480 --no-banner "${img_path}/${time}.jpg"

    docker run --rm \
      -v "$img_path:/app/capture" \
      docker_sender "$time Authentication failure from $pub_ip"

    mv ${img_path}/${time}.jpg /opt/denker/capture/archive/
  fi
done
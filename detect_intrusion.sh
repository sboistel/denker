#!/usr/bin/env bash

# VARS
time=$(date +%Y-%m-%d)
pub_ip=$(curl -s --max-time 2 ifconfig.me || echo "Uknown IP")
img_path="$(pwd)/capture"

# Check if required packages are installed
if ! command -v fswebcam &> /dev/null; then
  echo "fswebcam is not installed. Please install it to capture images."
  exit 1
fi

# Check if Docker image exists
denker_exists=$(docker image ls | grep "denker")
if [ ! -n "$denker_exists" ]; then
  docker build -t denker $(pwd)
fi

echo "Start monitoring authentication..."

# Watch for authentication failures
journalctl -f | while read -r line; do
  if echo "$line" | grep -q "pam_unix(gdm-password:auth): authentication failure"; then

    fswebcam -r 640x480 --no-banner "${img_path}/${time}.jpg"

    docker run --rm \
      -v "$img_path:/app/capture" \
      denker "$time Authentication failure from $pub_ip"

    mv ${img_path}/${time}.jpg ./capture/archive/
  fi
done

#!/usr/bin/env bash

# VARS
time=$(date +%Y-%m-%d)
pub_ip=$(curl -s --max-time 2 ifconfig.me || echo "Uknown IP")
img_path="$(dirname "$0")/capture"
picture_size="1920x1080" # 640x480

# Check if required packages are installed
if ! command -v fswebcam &> /dev/null; then
  echo "fswebcam is not installed. Please install it to capture images."
  exit 1
fi

# Check if Docker image exists
denker_exists=$(docker image ls | grep "denker")
if [ ! -n "$denker_exists" ]; then
  docker build -t denker $(dirname "$0")
fi

echo "Start monitoring authentication..."

# Watch for authentication failures
journalctl -f | while read -r line; do
  if echo "$line" | grep -q "pam_unix(gdm-password:auth): authentication failure"; then

    fswebcam -r "${picture_size}" --no-banner "${img_path}/${time}.jpg"

    # python3 send_email.py "Authentication failure detected" \
    #   --body "An authentication failure was detected from IP address: $pub_ip" \
    #   --attachment "${img_path}/${time}.jpg"

    docker run --rm \
      -v "$img_path:/app/capture" \
      denker "$time Authentication failure from $pub_ip"

    mv ${img_path}/${time}.jpg ./capture/archive/
  fi
done

# Denker - Intrusion Detection System

A lightweight intrusion detection system that monitors authentication failures on Linux systems and sends email alerts with webcam captures when unauthorized access attempts are detected.

## Features

- 🔍 Real-time monitoring of authentication failures via `journalctl`
- 📷 Automatic webcam capture when intrusion is detected
- 📧 Email notifications with attached images
- 🐳 Dockerized email service for easy deployment
- 🔄 Systemd service for automatic startup and restart
- 📁 Automatic archiving of captured images

## How It Works

1. The main script (`detect_intrusion.sh`) monitors system logs for authentication failures
2. When a failure is detected, it captures a photo using the webcam
3. A Docker container sends an email notification with the captured image attached
4. The image is then moved to an archive folder for storage

## Prerequisites

- Linux system with systemd
- Docker
- `fswebcam` package for webcam capture
- `journalctl` access (typically requires appropriate permissions)
- SMTP server credentials for email notifications

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/sboistel/denker.git
   cd denker
   ```

2. **Install required packages:**

   ```bash
   sudo apt update
   sudo apt install fswebcam docker.io
   ```

3. **Create environment file:**

   Create a `.env` file in the project directory with your SMTP configuration:

   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=465
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=your-app-password
   SMTP_FROM=your-email@gmail.com
   SMTP_TO=recipient@gmail.com
   SUBJECT=Security Alert
   ```

4. **Create necessary directories:**

   ```bash
   mkdir -p capture/archive
   ```

5. **Make the script executable:**

   ```bash
   chmod +x detect_intrusion.sh
   ```

## Usage

### Manual Execution

Run the intrusion detection script manually:

```bash
./detect_intrusion.sh
```

### System Service Installation

For automatic startup and monitoring:

1. **Copy files to system directory:**

   ```bash
   sudo mkdir -p /opt/denker
   sudo cp -r * /opt/denker/
   sudo chmod +x /opt/denker/detect_intrusion.sh
   ```

2. **Install and enable the service:**

   ```bash
   sudo cp intruder-watcher.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable intruder-watcher.service
   sudo systemctl start intruder-watcher.service
   ```

3. **Check service status:**

   ```bash
   sudo systemctl status intruder-watcher.service
   ```

## Configuration

### Environment Variables

The email functionality is configured via environment variables in the `.env` file:

- `SMTP_HOST`: SMTP server hostname
- `SMTP_PORT`: SMTP server port (usually 465 for SSL or 587 for TLS)
- `SMTP_USER`: SMTP username
- `SMTP_PASS`: SMTP password (use app passwords for Gmail)
- `SMTP_FROM`: Sender email address
- `SMTP_TO`: Recipient email address
- `SUBJECT`: Email subject line

### Webcam Settings

The webcam capture uses `fswebcam` with the following default settings:

- Resolution: 640x480
- No banner overlay
- JPEG format

You can modify these settings in the `detect_intrusion.sh` script.

## File Structure

```text
denker/
├── detect_intrusion.sh      # Main monitoring script
├── send_email.py           # Email notification script
├── Dockerfile              # Docker configuration for email service
├── intruder-watcher.service # Systemd service file
├── .env                    # Environment configuration (create this)
├── capture/                # Directory for captured images
│   └── archive/           # Archived images
└── README.md              # This file
```

## Monitoring and Logs

- **Service logs:** `sudo journalctl -u intruder-watcher.service -f`
- **Manual script output:** The script outputs to stdout when run manually
- **Captured images:** Stored in `capture/archive/` with date-based filenames

## Troubleshooting

### Common Issues

1. **Permission denied for journalctl:**
   - Ensure the user running the script has appropriate permissions
   - Consider running as a service with proper privileges

2. **Webcam not found:**
   - Check if `fswebcam` can access your camera: `fswebcam test.jpg`
   - Verify camera permissions and that no other application is using it

3. **Email not sending:**
   - Verify SMTP credentials in `.env` file
   - Check if your email provider requires app passwords
   - Ensure Docker is running and can build the image

4. **Docker build fails:**
   - Check if `.env` file exists in the project directory
   - Verify Docker service is running: `sudo systemctl status docker`

### Testing

Test individual components:

```bash
# Test webcam capture
fswebcam -r 640x480 --no-banner test.jpg

# Test email sending (requires Docker image to be built)
docker build -t denker .
docker run --rm -v "$(pwd)/capture:/app/capture" denker "Test message"

# Test authentication failure detection (simulate in another terminal)
# This will generate log entries that the script should detect
```

## Security Considerations

- Store SMTP credentials securely in the `.env` file
- Limit access to the project directory and `.env` file
- Consider using app passwords instead of main account passwords
- Regularly clean up archived images to manage disk space
- Monitor the service logs for any unusual activity

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source. Please check the repository for license details.

## Author

**sboistel** - [GitHub Profile](https://github.com/sboistel)

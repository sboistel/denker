import os
import sys
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables from .env file
load_dotenv(dotenv_path='/app/.env')

SMTP_HOST = os.getenv('SMTP_HOST')
SMTP_PORT = int(os.getenv('SMTP_PORT'))
SMTP_USER = os.getenv('SMTP_USER')
SMTP_PASS = os.getenv('SMTP_PASS')
SMTP_FROM = os.getenv('SMTP_FROM')
SMTP_TO = os.getenv('SMTP_TO')
SUBJECT = os.getenv('SUBJECT', 'Security Alert')

# Message
message = sys.argv[1] if len(sys.argv) > 1 else "Unknown event detected."

# Building the email
msg = MIMEMultipart()
msg['Subject'] = "Authentication failure on isaac"
msg['From'] = SMTP_FROM
msg['To'] = SMTP_TO
msg.attach(MIMEText(message, 'plain'))

# Adding the image
img_path = f"/app/capture/{datetime.now().strftime('%Y-%m-%d')}.jpg"
if os.path.isfile(img_path):
    print(f"Attaching image: {img_path}")
    with open(img_path, "rb") as f:
        part = MIMEImage(f.read(), name="capture.jpg")
        part.add_header('Content-Disposition', 'attachment', filename="capture.jpg")
        msg.attach(part)
else:
    print(f"No image found at: {img_path}")

# Sending the email
try:
    with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT) as server:
        server.login(SMTP_USER, SMTP_PASS)
        server.send_message(msg)
    print("Mail sent successfully.")
except Exception as e:
    print("Error:", e)
    exit(1)

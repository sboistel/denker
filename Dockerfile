FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN pip install python-dotenv

# Copy the script and any required files
COPY send_email.py .
COPY .env .

ENTRYPOINT ["python", "/app/send_email.py"]

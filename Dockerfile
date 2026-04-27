# ── Base image ────────────────────────────────────────────────────────────────
FROM python:3.12-slim

# Environment hygiene
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependencies first (better layer caching)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY app/ .

# Expose Flask port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
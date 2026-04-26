# ============================================================
# DevSecOps Demo — Dockerfile
#
# This Dockerfile contains INTENTIONAL issues.
# Do NOT use this in production.
# ============================================================

# ISSUE 1: Using python:3.8 (not slim, not alpine)
# An older, full base image with many OS-level packages = more CVE surface.
# The fix: use python:3.11-slim or python:3.11-alpine.
FROM python:3.8

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# ISSUE 2: No USER directive — container runs as root
# Running as root means if the app is compromised, the attacker
# has root inside the container.
# The fix:
#   RUN adduser --disabled-password --gecos '' appuser
#   USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
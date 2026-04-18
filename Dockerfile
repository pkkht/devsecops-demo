# ============================================================
# DevSecOps Demo — Dockerfile
#
# This Dockerfile contains INTENTIONAL issues.
# Trivy (image scan) will flag these in Episode 6.
# ============================================================

# ISSUE 1: Using python:3.8 (not slim, not alpine)
# An older, full base image with many OS-level packages = more CVE surface.
# Trivy will flag vulnerabilities in OS packages inside this image.
# The fix: use python:3.11-slim or python:3.11-alpine.
FROM python:3.8

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# ISSUE 2: No USER directive — container runs as root
# Trivy will flag this. Running as root means if the app
# is compromised, the attacker has root inside the container.
# The fix: add a non-root user and switch to it before CMD.
#
# Example fix:
#   RUN adduser --disabled-password --gecos '' appuser
#   USER appuser

EXPOSE 5000

CMD ["python", "app.py"]

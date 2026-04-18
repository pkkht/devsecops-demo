# DevSecOps Demo App

A simple Python Flask task manager API used throughout the **DevSecOps Pipeline in Azure DevOps** YouTube series.

> ⚠️ This app contains **intentional security vulnerabilities** for demo purposes. Do not deploy to production.

---

## What this app does

A basic REST API for managing tasks — create, list, and delete. Simple enough that the pipeline is the point, not the app.

## API endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /health | Health check |
| GET | /tasks | List all tasks (supports `?search=` param) |
| POST | /tasks | Create a task |
| DELETE | /tasks/:id | Delete a task |
| POST | /calculate | Evaluate an expression (intentionally vulnerable) |

## Run locally

```bash
pip install -r requirements.txt
python app.py
```

Then test it:

```bash
curl http://localhost:5000/health
curl -X POST http://localhost:5000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Fix the pipeline", "description": "Add Trivy scanning"}'
curl http://localhost:5000/tasks
```

## Run with Docker

```bash
docker build -t devsecops-demo .
docker run -p 5000:5000 devsecops-demo
```

---

## Intentional vulnerabilities

These are left in deliberately so the pipeline tools have something real to catch.

### Application code — SonarQube (SAST) catches these in Episode 3
| Location | Issue |
|----------|-------|
| `app.py` line 19 | Hardcoded secret key |
| `app.py` line 20 | Hardcoded API token |
| `app.py` line 23 | Debug mode hardcoded to True |
| `app.py` line 47 | SQL injection in `/tasks?search=` |
| `app.py` line 79 | `eval()` on user-supplied input |
| `app.py` line 85 | Listening on 0.0.0.0 with debug on |

### Dependencies — Snyk (SCA) catches these in Episode 4
| Package | Version | CVE |
|---------|---------|-----|
| Flask | 1.1.2 | Multiple |
| Jinja2 | 2.11.3 | CVE-2020-28493 |
| requests | 2.20.0 | CVE-2018-18074 |
| Pillow | 8.1.1 | CVE-2021-25291 and others |

### Docker image — Trivy catches these in Episode 6
| Issue | Detail |
|-------|--------|
| Old base image | `python:3.8` has many OS-level CVEs |
| Running as root | No `USER` directive in Dockerfile |

### Terraform — Checkov catches these in Episode 7
| Resource | Checkov Rule | Issue |
|----------|-------------|-------|
| `aws_s3_bucket` | CKV_AWS_19 | No server-side encryption |
| `aws_s3_bucket_acl` | CKV_AWS_20 | Public-read ACL |
| `aws_s3_bucket` | CKV_AWS_21 | Versioning not enabled |
| `aws_security_group` | CKV_AWS_25 | Ingress open to 0.0.0.0/0 |
| `aws_instance` | CKV_AWS_8 | Unencrypted EBS root volume |
| `aws_instance` | CKV_AWS_79 | IMDSv2 not enforced |

---

## Series episodes

| Episode | Topic |
|---------|-------|
| 1 | Architecture overview (this README) |
| 2 | Azure Repos + branch policies |
| 3 | SAST with SonarQube |
| 4 | SCA with Snyk |
| 5 | Docker build + push to ACR |
| 6 | Image scan with Trivy |
| 7 | IaC scan with Checkov |
| 8 | DAST with OWASP ZAP |
| 9 | Secrets with Azure Key Vault |
| 10 | Full pipeline end-to-end demo |

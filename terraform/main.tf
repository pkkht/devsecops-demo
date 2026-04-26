# ============================================================
# DevSecOps Demo — Terraform
#
# This file contains INTENTIONAL misconfigurations.
# Do NOT deploy this to production.
# ============================================================

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------
# MISCONFIGURATION 1: S3 bucket without server-side encryption
# Checkov rule: CKV_AWS_19
# All data stored in this bucket is unencrypted at rest.
# The fix: add a aws_s3_bucket_server_side_encryption_configuration block.
# ----------------------------------------------------------
resource "aws_s3_bucket" "app_storage" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    App         = "devsecops-demo"
  }
}

# ----------------------------------------------------------
# MISCONFIGURATION 2: S3 bucket set to public-read
# Checkov rule: CKV_AWS_20
# Exposes all objects in the bucket to the public internet.
# The fix: set acl = "private" and use bucket policies for access control.
# ----------------------------------------------------------
resource "aws_s3_bucket_acl" "app_storage_acl" {
  bucket = aws_s3_bucket.app_storage.id
  acl    = "public-read"
}

# ----------------------------------------------------------
# MISCONFIGURATION 3: S3 bucket versioning not enabled
# Checkov rule: CKV_AWS_21
# Without versioning, deleted or overwritten objects cannot be recovered.
# The fix: add aws_s3_bucket_versioning with status = "Enabled"
# ----------------------------------------------------------

# ----------------------------------------------------------
# MISCONFIGURATION 4: Security group open to 0.0.0.0/0 on ALL ports
# Checkov rule: CKV_AWS_25, CKV_AWS_24
# Allows any IP address to connect on any port.
# The fix: restrict ingress to specific ports (e.g. 443, 80)
# and restrict source CIDR to known ranges.
# ----------------------------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "devsecops-demo-sg"
  description = "Security group for demo app"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

# ----------------------------------------------------------
# MISCONFIGURATION 5: EC2 with unencrypted EBS root volume
# Checkov rule: CKV_AWS_8
# Data written to the root volume is stored unencrypted.
# The fix: set encrypted = true on the root_block_device.
# ----------------------------------------------------------
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size = 20
    encrypted   = false
  }

  # ----------------------------------------------------------
  # MISCONFIGURATION 6: No IMDSv2 enforcement
  # Checkov rule: CKV_AWS_79
  # Without IMDSv2, SSRF attacks can reach the instance metadata service.
  # The fix: add metadata_options { http_tokens = "required" }
  # ----------------------------------------------------------

  tags = {
    Name        = "devsecops-demo-server"
    Environment = var.environment
  }
}

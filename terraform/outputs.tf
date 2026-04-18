output "instance_public_ip" {
  description = "Public IP of the app server"
  value       = aws_instance.app_server.public_ip
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app_storage.bucket
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.app_sg.id
}

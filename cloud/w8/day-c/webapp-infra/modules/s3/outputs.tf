output "bucket_name" {
  description = "S3 bucket name for static assets"
  value       = aws_s3_bucket.static_assets.bucket
}

output "project_info_key" {
  description = "Sample static asset object key"
  value       = aws_s3_object.project_info.key
}

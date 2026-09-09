output "learning_bucket_arn" {
  description = "ARN of the primary logs bucket"
  value       = aws_s3_bucket.learning.arn
}

output "name_prefix" {
  description = "Prefix applied to all bucket names"
  value       = local.name_prefix
}

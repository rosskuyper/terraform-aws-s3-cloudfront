# https://www.terraform.io/docs/configuration/outputs.html

output "s3_bucket_name" {
  value       = aws_s3_bucket.main.id
  description = "Bucket name."
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.main.arn
  description = "Bucket arn."
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.main.id
  description = "Cloudfront distribution ID."
}

output "cloudfront_arn" {
  value       = aws_cloudfront_distribution.main.arn
  description = "Cloudfront distribution arn."
}

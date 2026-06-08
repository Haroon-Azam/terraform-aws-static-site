output "cloudfront_url" {
  description = "HTTPS URL of the CloudFront-served website"
  value       = "https://${aws_cloudfront_distribution.website_cdn.domain_name}"
}
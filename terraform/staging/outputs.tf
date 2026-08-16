output "staging_namespace" {
  description = "Name of the KijaniKiosk staging namespace"
  value       = kubernetes_namespace.staging.metadata[0].name
}

output "receipts_staging_bucket" {
  description = "S3 bucket used for KijaniKiosk staging payment receipts"
  value       = aws_s3_bucket.receipts_staging.bucket
}

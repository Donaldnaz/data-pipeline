output "raw_bucket_name" {
  value = aws_s3_bucket.raw_data.id
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.raw_data.arn
}

output "athena_results_bucket_name" {
  value = aws_s3_bucket.athena_results.id
}

output "athena_results_bucket_arn" {
  value = aws_s3_bucket.athena_results.arn
}

output "glue_scripts_bucket_name" {
  value = aws_s3_bucket.glue_scripts.id
}

output "glue_scripts_bucket_arn" {
  value = aws_s3_bucket.glue_scripts.arn
}

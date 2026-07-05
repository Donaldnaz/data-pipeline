output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "raw_data_bucket" {
  description = "S3 bucket where raw CSV data is uploaded"
  value       = module.s3.raw_bucket_name
}

output "athena_results_bucket" {
  description = "S3 bucket for Athena query results"
  value       = module.s3.athena_results_bucket_name
}

output "glue_database" {
  description = "Glue Data Catalog database name"
  value       = module.glue.database_name
}

output "glue_crawler_name" {
  description = "Glue Crawler name (catalogs all 3 tables)"
  value       = module.glue.crawler_name
}

output "glue_etl_job_name" {
  description = "Glue ETL job name (converts CSVs to Parquet)"
  value       = module.glue.etl_job_name
}

output "athena_workgroup" {
  description = "Athena workgroup name"
  value       = module.athena.workgroup_name
}

output "quicksight_role_arn" {
  description = "IAM role ARN attached to QuickSight data source"
  value       = module.iam.quicksight_role_arn
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "run_crawler_command" {
  description = "CLI command to start the Glue Crawler"
  value       = "aws glue start-crawler --name ${module.glue.crawler_name} --region ${var.aws_region}"
}

output "athena_console_url" {
  description = "URL to open Athena in the AWS Console"
  value       = "https://${var.aws_region}.console.aws.amazon.com/athena/home?region=${var.aws_region}#/query-editor"
}

output "quicksight_console_url" {
  description = "URL to open Amazon QuickSight"
  value       = "https://quicksight.aws.amazon.com/"
}

output "quicksight_dashboard_url" {
  description = "Direct URL to the published Iran War Oil Shock dashboard"
  value       = module.quicksight.dashboard_url
}

output "quicksight_analysis_url" {
  description = "Direct URL to the editable analysis"
  value       = module.quicksight.analysis_url
}

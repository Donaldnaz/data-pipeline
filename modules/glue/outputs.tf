output "database_name" {
  value = aws_glue_catalog_database.oil_db.name
}

output "crawler_name" {
  value = aws_glue_crawler.oil_crawler.name
}

output "etl_job_name" {
  value = aws_glue_job.csv_to_parquet.name
}

resource "aws_glue_catalog_database" "oil_db" {
  name        = "${var.db_name}_db"
  description = "Glue Data Catalog for Iran War Oil Shock 2026 dataset"
}

resource "aws_glue_classifier" "csv_classifier" {
  name = "${var.project_name}-csv-classifier"

  csv_classifier {
    contains_header        = "PRESENT"
    delimiter              = ","
    quote_symbol           = "\""
    allow_single_column    = false
    disable_value_trimming = false
  }
}

resource "aws_glue_crawler" "oil_crawler" {
  name          = "${var.project_name}-crawler"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.oil_db.name
  description   = "Crawls all three Iran War Oil Shock CSVs on S3"
  classifiers   = [aws_glue_classifier.csv_classifier.name]

  s3_target {
    path = "s3://${var.raw_bucket_name}/iran_war_oil_prices_daily_2026/"
  }

  s3_target {
    path = "s3://${var.raw_bucket_name}/iran_war_gas_prices_by_state/"
  }

  s3_target {
    path = "s3://${var.raw_bucket_name}/iran_war_key_events_timeline/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })
}

resource "aws_s3_object" "etl_script" {
  bucket = var.glue_scripts_bucket_name
  key    = "scripts/csv_to_parquet.py"
  source = "${path.module}/scripts/csv_to_parquet.py"
  etag   = filemd5("${path.module}/scripts/csv_to_parquet.py")
}

resource "aws_glue_job" "csv_to_parquet" {
  name              = "${var.project_name}-csv-to-parquet"
  role_arn          = var.glue_role_arn
  description       = "Converts all three Iran War Oil Shock CSVs to Parquet on S3"
  glue_version      = "4.0"
  worker_type       = var.glue_worker_type
  number_of_workers = var.glue_number_of_workers

  command {
    name            = "glueetl"
    script_location = "s3://${var.glue_scripts_bucket_name}/scripts/csv_to_parquet.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--database"            = aws_glue_catalog_database.oil_db.name
    "--dest_path"           = "s3://${var.raw_bucket_name}/parquet-output"
  }

  depends_on = [aws_s3_object.etl_script]
}

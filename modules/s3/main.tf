locals {
  raw_bucket_name       = "${var.project_name}-raw-data-${var.account_id}"
  athena_results_bucket = "${var.project_name}-athena-results-${var.account_id}"
  glue_scripts_bucket   = "${var.project_name}-glue-scripts-${var.account_id}"
}

resource "aws_s3_bucket" "raw_data" {
  bucket        = local.raw_bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = local.athena_results_bucket
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket        = local.glue_scripts_bucket
  force_destroy = var.force_destroy
}

resource "aws_s3_object" "oil_prices_csv" {
  bucket = aws_s3_bucket.raw_data.id
  key    = "iran_war_oil_prices_daily_2026/iran_war_oil_prices_daily_2026.csv"
  source = "${var.kaggle_data_path}/iran_war_oil_prices_daily_2026.csv"
  etag   = filemd5("${var.kaggle_data_path}/iran_war_oil_prices_daily_2026.csv")
}

resource "aws_s3_object" "gas_prices_csv" {
  bucket = aws_s3_bucket.raw_data.id
  key    = "iran_war_gas_prices_by_state/iran_war_gas_prices_by_state.csv"
  source = "${var.kaggle_data_path}/iran_war_gas_prices_by_state.csv"
  etag   = filemd5("${var.kaggle_data_path}/iran_war_gas_prices_by_state.csv")
}

resource "aws_s3_object" "key_events_csv" {
  bucket = aws_s3_bucket.raw_data.id
  key    = "iran_war_key_events_timeline/iran_war_key_events_timeline.csv"
  source = "${var.kaggle_data_path}/iran_war_key_events_timeline.csv"
  etag   = filemd5("${var.kaggle_data_path}/iran_war_key_events_timeline.csv")
}

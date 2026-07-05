data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  db_name    = replace(var.project_name, "-", "_")
}

module "s3" {
  source               = "./modules/s3"
  project_name         = var.project_name
  account_id           = local.account_id
  kaggle_data_path     = var.kaggle_data_path
  force_destroy        = var.force_destroy
  enable_s3_versioning = var.enable_s3_versioning
}

module "iam" {
  source                    = "./modules/iam"
  project_name              = var.project_name
  aws_region                = var.aws_region
  account_id                = local.account_id
  raw_bucket_arn            = module.s3.raw_bucket_arn
  glue_scripts_bucket_arn   = module.s3.glue_scripts_bucket_arn
  athena_results_bucket_arn = module.s3.athena_results_bucket_arn
}

module "glue" {
  source                   = "./modules/glue"
  project_name             = var.project_name
  db_name                  = local.db_name
  raw_bucket_name          = module.s3.raw_bucket_name
  glue_scripts_bucket_name = module.s3.glue_scripts_bucket_name
  glue_role_arn            = module.iam.glue_role_arn
  glue_worker_type         = var.glue_worker_type
  glue_number_of_workers   = var.glue_number_of_workers
}

module "athena" {
  source                     = "./modules/athena"
  project_name               = var.project_name
  database_name              = module.glue.database_name
  athena_results_bucket_name = module.s3.athena_results_bucket_name
}

module "quicksight" {
  source                = "./modules/quicksight"
  project_name          = var.project_name
  aws_region            = var.aws_region
  account_id            = local.account_id
  quicksight_username   = var.quicksight_username
  athena_workgroup_name = module.athena.workgroup_name
  glue_database_name    = module.glue.database_name
  quicksight_role_arn   = module.iam.quicksight_role_arn
  data_source_name      = var.data_source_name
  dashboard_name        = var.dashboard_name
  analysis_name         = var.analysis_name
  template_name         = var.template_name

  depends_on = [module.iam, module.athena]
}

# State migration — preserves existing resources when refactoring into modules

moved {
  from = aws_s3_bucket.raw_data
  to   = module.s3.aws_s3_bucket.raw_data
}

moved {
  from = aws_s3_bucket_versioning.raw_data
  to   = module.s3.aws_s3_bucket_versioning.raw_data
}

moved {
  from = aws_s3_bucket.athena_results
  to   = module.s3.aws_s3_bucket.athena_results
}

moved {
  from = aws_s3_bucket.glue_scripts
  to   = module.s3.aws_s3_bucket.glue_scripts
}

moved {
  from = aws_s3_object.oil_prices_csv
  to   = module.s3.aws_s3_object.oil_prices_csv
}

moved {
  from = aws_s3_object.gas_prices_csv
  to   = module.s3.aws_s3_object.gas_prices_csv
}

moved {
  from = aws_s3_object.key_events_csv
  to   = module.s3.aws_s3_object.key_events_csv
}

moved {
  from = aws_iam_role.glue_role
  to   = module.iam.aws_iam_role.glue_role
}

moved {
  from = aws_iam_role_policy.glue_s3_access
  to   = module.iam.aws_iam_role_policy.glue_s3_access
}

moved {
  from = aws_iam_role_policy_attachment.glue_service_role
  to   = module.iam.aws_iam_role_policy_attachment.glue_service_role
}

moved {
  from = aws_iam_role.quicksight_role
  to   = module.iam.aws_iam_role.quicksight_role
}

moved {
  from = aws_iam_role_policy.quicksight_policy
  to   = module.iam.aws_iam_role_policy.quicksight_policy
}

moved {
  from = data.aws_iam_role.quicksight_service_role
  to   = module.iam.data.aws_iam_role.quicksight_service_role
}

moved {
  from = aws_iam_role_policy.quicksight_service_s3
  to   = module.iam.aws_iam_role_policy.quicksight_service_s3
}

moved {
  from = aws_glue_catalog_database.oil_db
  to   = module.glue.aws_glue_catalog_database.oil_db
}

moved {
  from = aws_glue_classifier.csv_classifier
  to   = module.glue.aws_glue_classifier.csv_classifier
}

moved {
  from = aws_glue_crawler.oil_crawler
  to   = module.glue.aws_glue_crawler.oil_crawler
}

moved {
  from = aws_s3_object.etl_script
  to   = module.glue.aws_s3_object.etl_script
}

moved {
  from = aws_glue_job.csv_to_parquet
  to   = module.glue.aws_glue_job.csv_to_parquet
}

moved {
  from = aws_athena_workgroup.oil_workgroup
  to   = module.athena.aws_athena_workgroup.oil_workgroup
}

moved {
  from = aws_athena_named_query.brent_daily_trend
  to   = module.athena.aws_athena_named_query.brent_daily_trend
}

moved {
  from = aws_athena_named_query.us_gas_impact
  to   = module.athena.aws_athena_named_query.us_gas_impact
}

moved {
  from = aws_athena_named_query.gas_price_by_state
  to   = module.athena.aws_athena_named_query.gas_price_by_state
}

moved {
  from = aws_athena_named_query.regional_gas_summary
  to   = module.athena.aws_athena_named_query.regional_gas_summary
}

moved {
  from = aws_athena_named_query.key_events_with_price
  to   = module.athena.aws_athena_named_query.key_events_with_price
}

moved {
  from = aws_athena_named_query.hormuz_closure_impact
  to   = module.athena.aws_athena_named_query.hormuz_closure_impact
}

moved {
  from = aws_quicksight_data_source.athena
  to   = module.quicksight.aws_quicksight_data_source.athena
}

moved {
  from = aws_quicksight_data_set.oil_prices
  to   = module.quicksight.aws_quicksight_data_set.oil_prices
}

moved {
  from = aws_quicksight_data_set.gas_prices
  to   = module.quicksight.aws_quicksight_data_set.gas_prices
}

moved {
  from = aws_quicksight_data_set.key_events
  to   = module.quicksight.aws_quicksight_data_set.key_events
}

moved {
  from = aws_quicksight_analysis.oil_shock
  to   = module.quicksight.aws_quicksight_analysis.oil_shock
}

moved {
  from = aws_quicksight_template.oil_shock
  to   = module.quicksight.aws_quicksight_template.oil_shock
}

moved {
  from = aws_quicksight_dashboard.oil_shock
  to   = module.quicksight.aws_quicksight_dashboard.oil_shock
}

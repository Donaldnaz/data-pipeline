variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "quicksight_username" {
  type = string
}

variable "athena_workgroup_name" {
  type = string
}

variable "glue_database_name" {
  type = string
}

variable "quicksight_role_arn" {
  type = string
}

variable "data_source_name" {
  type = string
}

variable "dashboard_name" {
  type = string
}

variable "analysis_name" {
  type = string
}

variable "template_name" {
  type = string
}

locals {
  quicksight_user_principal = "arn:aws:quicksight:${var.aws_region}:${var.account_id}:user/default/${var.quicksight_username}"
}

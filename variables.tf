# ------------------------------------------------------------------------------
# Core / environment
# Set values in environments/<env>.tfvars (see dev.tfvars.example)
# ------------------------------------------------------------------------------

variable "environment" {
  description = "Deployment environment used for tagging and outputs"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region where all resources are deployed"
  type        = string
}

variable "project_name" {
  description = "Prefix for all resource names; include env suffix (e.g. s3-athena-qs-demo-dev)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Extra tags merged with Environment, Project, and ManagedBy on all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# S3
# ------------------------------------------------------------------------------

variable "kaggle_data_path" {
  description = "Local directory containing the three Kaggle CSV source files"
  type        = string
}

variable "force_destroy" {
  description = "Allow S3 buckets to be destroyed with contents (true for dev, false for prod)"
  type        = bool
}

variable "enable_s3_versioning" {
  description = "Enable versioning on the raw data S3 bucket"
  type        = bool
}

# ------------------------------------------------------------------------------
# Glue
# ------------------------------------------------------------------------------

variable "glue_worker_type" {
  description = "Glue ETL job worker type (G.1X, G.2X, G.025X, G.4X, G.8X, or Z.2X)"
  type        = string

  validation {
    condition     = contains(["G.1X", "G.2X", "G.025X", "G.4X", "G.8X", "Z.2X"], var.glue_worker_type)
    error_message = "glue_worker_type must be a valid Glue worker type."
  }
}

variable "glue_number_of_workers" {
  description = "Number of workers for the Glue CSV-to-Parquet ETL job"
  type        = number

  validation {
    condition     = var.glue_number_of_workers >= 2
    error_message = "glue_number_of_workers must be at least 2 for distributed Glue ETL jobs."
  }
}

# ------------------------------------------------------------------------------
# QuickSight
# ------------------------------------------------------------------------------

variable "quicksight_username" {
  description = "QuickSight username for dataset and dashboard permissions"
  type        = string
  sensitive   = true
}

variable "data_source_name" {
  description = "Display name for the QuickSight Athena data source"
  type        = string
  default     = "Iran War Oil Shock — Athena"
}

variable "analysis_name" {
  description = "Display name for the QuickSight analysis"
  type        = string
  default     = "Iran War Oil Shock 2026"
}

variable "template_name" {
  description = "Display name for the QuickSight template"
  type        = string
  default     = "Iran War Oil Shock 2026 Template"
}

variable "dashboard_name" {
  description = "Display name for the QuickSight dashboard"
  type        = string
  default     = "Iran War Oil Shock 2026"
}

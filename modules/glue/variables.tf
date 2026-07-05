variable "project_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "raw_bucket_name" {
  type = string
}

variable "glue_scripts_bucket_name" {
  type = string
}

variable "glue_role_arn" {
  type = string
}

variable "glue_worker_type" {
  type = string
}

variable "glue_number_of_workers" {
  type = number
}

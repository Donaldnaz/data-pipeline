resource "aws_quicksight_data_source" "athena" {
  data_source_id = "${var.project_name}-athena-source"
  name           = var.data_source_name
  aws_account_id = var.account_id
  type           = "ATHENA"

  parameters {
    athena {
      work_group = var.athena_workgroup_name
      role_arn   = var.quicksight_role_arn
    }
  }

  permission {
    actions = [
      "quicksight:DescribeDataSource",
      "quicksight:DescribeDataSourcePermissions",
      "quicksight:PassDataSource",
      "quicksight:UpdateDataSource",
      "quicksight:DeleteDataSource",
      "quicksight:UpdateDataSourcePermissions"
    ]
    principal = local.quicksight_user_principal
  }

  ssl_properties {
    disable_ssl = false
  }
}

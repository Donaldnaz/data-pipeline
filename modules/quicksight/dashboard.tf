resource "aws_quicksight_template" "oil_shock" {
  template_id         = "${var.project_name}-template"
  name                = var.template_name
  aws_account_id      = var.account_id
  version_description = "v3-clear-titles"

  source_entity {
    source_analysis {
      arn = aws_quicksight_analysis.oil_shock.arn
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.oil_prices.arn
        data_set_placeholder = "OilPricesDaily"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.gas_prices.arn
        data_set_placeholder = "GasPricesByState"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.key_events.arn
        data_set_placeholder = "KeyEventsTimeline"
      }
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeTemplate",
      "quicksight:DescribeTemplatePermissions",
      "quicksight:UpdateTemplatePermissions",
      "quicksight:UpdateTemplateAlias",
      "quicksight:DeleteTemplateAlias",
      "quicksight:DescribeTemplateAlias",
      "quicksight:ListTemplateAliases",
      "quicksight:ListTemplates"
    ]
    principal = local.quicksight_user_principal
  }

  depends_on = [aws_quicksight_analysis.oil_shock]
}

resource "aws_quicksight_dashboard" "oil_shock" {
  dashboard_id        = "${var.project_name}-dashboard"
  name                = var.dashboard_name
  aws_account_id      = var.account_id
  version_description = "v3-clear-titles"
  theme_arn           = aws_quicksight_theme.oil_shock.arn

  source_entity {
    source_template {
      arn = aws_quicksight_template.oil_shock.arn
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.oil_prices.arn
        data_set_placeholder = "OilPricesDaily"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.gas_prices.arn
        data_set_placeholder = "GasPricesByState"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.key_events.arn
        data_set_placeholder = "KeyEventsTimeline"
      }
    }
  }

  dashboard_publish_options {
    ad_hoc_filtering_option {
      availability_status = "ENABLED"
    }
    export_to_csv_option {
      availability_status = "ENABLED"
    }
    sheet_controls_option {
      visibility_state = "EXPANDED"
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeDashboard",
      "quicksight:ListDashboardVersions",
      "quicksight:UpdateDashboardPermissions",
      "quicksight:QueryDashboard",
      "quicksight:UpdateDashboard",
      "quicksight:DeleteDashboard",
      "quicksight:DescribeDashboardPermissions",
      "quicksight:UpdateDashboardPublishedVersion"
    ]
    principal = local.quicksight_user_principal
  }

  depends_on = [
    aws_quicksight_template.oil_shock,
    aws_quicksight_theme.oil_shock
  ]
}

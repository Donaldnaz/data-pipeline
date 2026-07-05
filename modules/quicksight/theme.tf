resource "aws_quicksight_theme" "oil_shock" {
  theme_id      = "${var.project_name}-theme"
  name          = "Iran War Oil Shock — Dark Energy"
  aws_account_id = var.account_id
  base_theme_id = "MIDNIGHT"

  configuration {
    data_color_palette {
      colors = [
        "#F4A623",
        "#E67E22",
        "#3498DB",
        "#2ECC71",
        "#E74C3C",
        "#9B59B6",
        "#1ABC9C",
        "#F39C12",
      ]
      empty_fill_color = "#1A1A2E"
      min_max_gradient = ["#2ECC71", "#E74C3C"]
    }

    ui_color_palette {
      primary_background   = "#0F0F1A"
      primary_foreground   = "#E8E8E8"
      secondary_background = "#1A1A2E"
      secondary_foreground = "#CCCCCC"
      accent               = "#F4A623"
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeTheme",
      "quicksight:DescribeThemePermissions",
      "quicksight:ListThemeVersions",
      "quicksight:UpdateThemePermissions",
      "quicksight:UpdateTheme",
      "quicksight:DeleteTheme",
      "quicksight:CreateThemeAlias",
      "quicksight:UpdateThemeAlias",
      "quicksight:DeleteThemeAlias",
      "quicksight:DescribeThemeAlias",
      "quicksight:ListThemeAliases",
    ]
    principal = local.quicksight_user_principal
  }
}

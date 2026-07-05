resource "aws_quicksight_data_set" "oil_prices" {
  data_set_id     = "${var.project_name}-oil-prices"
  name           = "Oil Prices Daily"
  aws_account_id = var.account_id
  import_mode    = "SPICE"

  physical_table_map {
    physical_table_map_id = "oil-prices-table"

    relational_table {
      data_source_arn = aws_quicksight_data_source.athena.arn
      catalog         = "AWSDataCatalog"
      schema          = var.glue_database_name
      name            = "iran_war_oil_prices_daily_2026"

      input_columns {
        name = "date"
        type = "STRING"
      }
      input_columns {
        name = "brent_usd_barrel"
        type = "DECIMAL"
      }
      input_columns {
        name = "wti_usd_barrel"
        type = "DECIMAL"
      }
      input_columns {
        name = "dubai_usd_barrel"
        type = "DECIMAL"
      }
      input_columns {
        name = "us_gas_avg_gallon"
        type = "DECIMAL"
      }
      input_columns {
        name = "us_diesel_avg_gallon"
        type = "DECIMAL"
      }
      input_columns {
        name = "strait_hormuz_daily_ships"
        type = "INTEGER"
      }
      input_columns {
        name = "iran_production_mbpd"
        type = "DECIMAL"
      }
      input_columns {
        name = "brent_vs_prewar_pct"
        type = "DECIMAL"
      }
      input_columns {
        name = "gas_vs_prewar_pct"
        type = "DECIMAL"
      }
      input_columns {
        name = "gas_change_from_prewar_dollars"
        type = "DECIMAL"
      }
      input_columns {
        name = "phase"
        type = "STRING"
      }
      input_columns {
        name = "war_day"
        type = "INTEGER"
      }
      input_columns {
        name = "key_event"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "oil-prices-logical"
    alias                = "OilPricesDaily"

    source {
      physical_table_id = "oil-prices-table"
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeDataSet",
      "quicksight:DescribeDataSetPermissions",
      "quicksight:PassDataSet",
      "quicksight:DescribeIngestion",
      "quicksight:ListIngestions",
      "quicksight:UpdateDataSet",
      "quicksight:DeleteDataSet",
      "quicksight:CreateIngestion",
      "quicksight:CancelIngestion",
      "quicksight:UpdateDataSetPermissions"
    ]
    principal = local.quicksight_user_principal
  }

  depends_on = [aws_quicksight_data_source.athena]
}

resource "aws_quicksight_data_set" "gas_prices" {
  data_set_id     = "${var.project_name}-gas-prices"
  name           = "Gas Prices By State"
  aws_account_id = var.account_id
  import_mode    = "SPICE"

  physical_table_map {
    physical_table_map_id = "gas-prices-table"

    relational_table {
      data_source_arn = aws_quicksight_data_source.athena.arn
      catalog         = "AWSDataCatalog"
      schema          = var.glue_database_name
      name            = "iran_war_gas_prices_by_state"

      input_columns {
        name = "state"
        type = "STRING"
      }
      input_columns {
        name = "region"
        type = "STRING"
      }
      input_columns {
        name = "gas_price_jan08_2026"
        type = "DECIMAL"
      }
      input_columns {
        name = "gas_price_prewar_feb27"
        type = "DECIMAL"
      }
      input_columns {
        name = "gas_price_mar19_2026"
        type = "DECIMAL"
      }
      input_columns {
        name = "price_increase_since_war"
        type = "DECIMAL"
      }
      input_columns {
        name = "pct_increase_since_war"
        type = "DECIMAL"
      }
      input_columns {
        name = "price_vs_national_avg"
        type = "DECIMAL"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "gas-prices-logical"
    alias                = "GasPricesByState"

    source {
      physical_table_id = "gas-prices-table"
    }

    data_transforms {
      tag_column_operation {
        column_name = "state"
        tags {
          column_geographic_role = "STATE"
        }
      }
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeDataSet",
      "quicksight:DescribeDataSetPermissions",
      "quicksight:PassDataSet",
      "quicksight:DescribeIngestion",
      "quicksight:ListIngestions",
      "quicksight:UpdateDataSet",
      "quicksight:DeleteDataSet",
      "quicksight:CreateIngestion",
      "quicksight:CancelIngestion",
      "quicksight:UpdateDataSetPermissions"
    ]
    principal = local.quicksight_user_principal
  }

  depends_on = [aws_quicksight_data_source.athena]
}

resource "aws_quicksight_data_set" "key_events" {
  data_set_id     = "${var.project_name}-key-events"
  name           = "Key Events Timeline"
  aws_account_id = var.account_id
  import_mode    = "SPICE"

  physical_table_map {
    physical_table_map_id = "key-events-table"

    relational_table {
      data_source_arn = aws_quicksight_data_source.athena.arn
      catalog         = "AWSDataCatalog"
      schema          = var.glue_database_name
      name            = "iran_war_key_events_timeline"

      input_columns {
        name = "date"
        type = "STRING"
      }
      input_columns {
        name = "event_title"
        type = "STRING"
      }
      input_columns {
        name = "description"
        type = "STRING"
      }
      input_columns {
        name = "war_day"
        type = "INTEGER"
      }
      input_columns {
        name = "category"
        type = "STRING"
      }
      input_columns {
        name = "brent_price_that_day"
        type = "DECIMAL"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "key-events-logical"
    alias                = "KeyEventsTimeline"

    source {
      physical_table_id = "key-events-table"
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeDataSet",
      "quicksight:DescribeDataSetPermissions",
      "quicksight:PassDataSet",
      "quicksight:DescribeIngestion",
      "quicksight:ListIngestions",
      "quicksight:UpdateDataSet",
      "quicksight:DeleteDataSet",
      "quicksight:CreateIngestion",
      "quicksight:CancelIngestion",
      "quicksight:UpdateDataSetPermissions"
    ]
    principal = local.quicksight_user_principal
  }

  depends_on = [aws_quicksight_data_source.athena]
}

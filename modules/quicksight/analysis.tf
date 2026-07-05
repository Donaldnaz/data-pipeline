resource "aws_quicksight_analysis" "oil_shock" {
  analysis_id    = "${var.project_name}-analysis"
  name           = var.analysis_name
  aws_account_id = var.account_id

  definition {
    data_set_identifiers_declarations {
      identifier   = "OilPricesDaily"
      data_set_arn = aws_quicksight_data_set.oil_prices.arn
    }
    data_set_identifiers_declarations {
      identifier   = "GasPricesByState"
      data_set_arn = aws_quicksight_data_set.gas_prices.arn
    }
    data_set_identifiers_declarations {
      identifier   = "KeyEventsTimeline"
      data_set_arn = aws_quicksight_data_set.key_events.arn
    }

    column_configurations {
      column {
        data_set_identifier = "OilPricesDaily"
        column_name         = "brent_usd_barrel"
      }
      format_configuration {
        number_format_configuration {
          numeric_format_configuration {
            currency_display_format_configuration {
              symbol = "USD"
              decimal_places_configuration {
                decimal_places = 2
              }
            }
          }
        }
      }
    }

    column_configurations {
      column {
        data_set_identifier = "OilPricesDaily"
        column_name         = "wti_usd_barrel"
      }
      format_configuration {
        number_format_configuration {
          numeric_format_configuration {
            currency_display_format_configuration {
              symbol = "USD"
              decimal_places_configuration {
                decimal_places = 2
              }
            }
          }
        }
      }
    }

    column_configurations {
      column {
        data_set_identifier = "OilPricesDaily"
        column_name         = "brent_vs_prewar_pct"
      }
      format_configuration {
        number_format_configuration {
          numeric_format_configuration {
            percentage_display_format_configuration {
              decimal_places_configuration {
                decimal_places = 1
              }
            }
          }
        }
      }
    }

    column_configurations {
      column {
        data_set_identifier = "OilPricesDaily"
        column_name         = "us_gas_avg_gallon"
      }
      format_configuration {
        number_format_configuration {
          numeric_format_configuration {
            currency_display_format_configuration {
              symbol = "USD"
              decimal_places_configuration {
                decimal_places = 2
              }
            }
          }
        }
      }
    }

    column_configurations {
      column {
        data_set_identifier = "GasPricesByState"
        column_name         = "gas_price_mar19_2026"
      }
      format_configuration {
        number_format_configuration {
          numeric_format_configuration {
            currency_display_format_configuration {
              symbol = "USD"
              decimal_places_configuration {
                decimal_places = 2
              }
            }
          }
        }
      }
    }

    column_configurations {
      column {
        data_set_identifier = "GasPricesByState"
        column_name         = "pct_increase_since_war"
      }
      format_configuration {
        number_format_configuration {
          numeric_format_configuration {
            percentage_display_format_configuration {
              decimal_places_configuration {
                decimal_places = 1
              }
            }
          }
        }
      }
    }

    # -------------------------------------------------------------------------
    # Sheet 1 — Oil Price Shock
    # -------------------------------------------------------------------------
    sheets {
      sheet_id = "sheet-oil-prices"
      name     = "Global Oil & Gas Prices"

      layouts {
        configuration {
          grid_layout {
            elements {
              element_id   = "peak-brent-kpi"
              element_type = "VISUAL"
              column_index = "0"
              column_span  = 9
              row_index    = "0"
              row_span     = 4
            }
            elements {
              element_id   = "peak-wti-kpi"
              element_type = "VISUAL"
              column_index = "9"
              column_span  = 9
              row_index    = "0"
              row_span     = 4
            }
            elements {
              element_id   = "peak-brent-pct-kpi"
              element_type = "VISUAL"
              column_index = "18"
              column_span  = 9
              row_index    = "0"
              row_span     = 4
            }
            elements {
              element_id   = "peak-gas-kpi"
              element_type = "VISUAL"
              column_index = "27"
              column_span  = 9
              row_index    = "0"
              row_span     = 4
            }
            elements {
              element_id   = "crude-lines"
              element_type = "VISUAL"
              column_index = "0"
              column_span  = 36
              row_index    = "4"
              row_span     = 12
            }
            elements {
              element_id   = "brent-hormuz-combo"
              element_type = "VISUAL"
              column_index = "0"
              column_span  = 36
              row_index    = "16"
              row_span     = 12
            }
          }
        }
      }

      visuals {
        kpi_visual {
          visual_id = "peak-brent-kpi"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Highest Brent Crude Price"
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "peak-brent-field"
                  column {
                    data_set_identifier = "OilPricesDaily"
                    column_name         = "brent_usd_barrel"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "MAX"
                  }
                }
              }
            }
          }
        }
      }

      visuals {
        kpi_visual {
          visual_id = "peak-wti-kpi"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Highest WTI Crude Price"
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "peak-wti-field"
                  column {
                    data_set_identifier = "OilPricesDaily"
                    column_name         = "wti_usd_barrel"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "MAX"
                  }
                }
              }
            }
          }
        }
      }

      visuals {
        kpi_visual {
          visual_id = "peak-brent-pct-kpi"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Peak Brent Rise vs Feb 27"
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "peak-brent-pct-field"
                  column {
                    data_set_identifier = "OilPricesDaily"
                    column_name         = "brent_vs_prewar_pct"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "MAX"
                  }
                }
              }
            }
          }
        }
      }

      visuals {
        kpi_visual {
          visual_id = "peak-gas-kpi"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Highest National Gas Price"
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "peak-gas-field"
                  column {
                    data_set_identifier = "OilPricesDaily"
                    column_name         = "us_gas_avg_gallon"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "MAX"
                  }
                }
              }
            }
          }
        }
      }

      visuals {
        line_chart_visual {
          visual_id = "crude-lines"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Global Crude Benchmarks Over Time"
            }
          }
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "date-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "date"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "brent-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "brent_usd_barrel"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "wti-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "wti_usd_barrel"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dubai-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "dubai_usd_barrel"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "date-field"
                  direction = "ASC"
                }
              }
            }
            legend {
              position = "RIGHT"
              visibility = "VISIBLE"
            }
          }
        }
      }

      visuals {
        combo_chart_visual {
          visual_id = "brent-hormuz-combo"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Brent Price & Hormuz Shipping Disruptions"
            }
          }
          chart_configuration {
            field_wells {
              combo_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "date-combo-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "date"
                    }
                  }
                }
                bar_values {
                  numerical_measure_field {
                    field_id = "brent-combo-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "brent_usd_barrel"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                line_values {
                  numerical_measure_field {
                    field_id = "hormuz-combo-field"
                    column {
                      data_set_identifier = "OilPricesDaily"
                      column_name         = "strait_hormuz_daily_ships"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
              }
            }
            legend {
              position   = "BOTTOM"
              visibility = "VISIBLE"
            }
          }
        }
      }
    }

    # -------------------------------------------------------------------------
    # Sheet 2 — US Gas Impact
    # -------------------------------------------------------------------------
    sheets {
      sheet_id = "sheet-gas-prices"
      name     = "US Pump Prices by State"

      layouts {
        configuration {
          grid_layout {
            elements {
              element_id   = "gas-state-map"
              element_type = "VISUAL"
              column_index = "0"
              column_span  = 18
              row_index    = "0"
              row_span     = 14
            }
            elements {
              element_id   = "gas-by-state-bar"
              element_type = "VISUAL"
              column_index = "18"
              column_span  = 18
              row_index    = "0"
              row_span     = 14
            }
            elements {
              element_id   = "region-prewar-war-bar"
              element_type = "VISUAL"
              column_index = "0"
              column_span  = 36
              row_index    = "14"
              row_span     = 10
            }
          }
        }
      }

      visuals {
        filled_map_visual {
          visual_id = "gas-state-map"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Where Gas Prices Are Highest (Mar 19, 2026)"
            }
          }
          chart_configuration {
            field_wells {
              filled_map_aggregated_field_wells {
                geospatial {
                  categorical_dimension_field {
                    field_id = "state-geo-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "state"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "gas-map-value"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "gas_price_mar19_2026"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
              }
            }
            legend {
              visibility = "VISIBLE"
            }
          }
        }
      }

      visuals {
        bar_chart_visual {
          visual_id = "gas-by-state-bar"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "States Ranked by Gas Price (Mar 19)"
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "state-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "state"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "gas-mar19-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "gas_price_mar19_2026"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                colors {
                  categorical_dimension_field {
                    field_id = "region-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "region"
                    }
                  }
                }
              }
            }
            orientation = "HORIZONTAL"
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "gas-mar19-field"
                  direction = "DESC"
                }
              }
            }
            legend {
              position   = "RIGHT"
              visibility = "VISIBLE"
            }
          }
        }
      }

      visuals {
        bar_chart_visual {
          visual_id = "region-prewar-war-bar"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Regional Average: Before War vs Mar 19"
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "region-cat-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "region"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "prewar-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "gas_price_prewar_feb27"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "warday-field"
                    column {
                      data_set_identifier = "GasPricesByState"
                      column_name         = "gas_price_mar19_2026"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
              }
            }
            orientation = "VERTICAL"
            legend {
              position   = "BOTTOM"
              visibility = "VISIBLE"
            }
          }
        }
      }
    }

    # -------------------------------------------------------------------------
    # Sheet 3 — War Events Timeline
    # -------------------------------------------------------------------------
    sheets {
      sheet_id = "sheet-war-events"
      name     = "War Events vs Oil Prices"

      layouts {
        configuration {
          grid_layout {
            elements {
              element_id   = "events-scatter"
              element_type = "VISUAL"
              column_index = "0"
              column_span  = 20
              row_index    = "0"
              row_span     = 14
            }
            elements {
              element_id   = "events-table"
              element_type = "VISUAL"
              column_index = "20"
              column_span  = 16
              row_index    = "0"
              row_span     = 14
            }
          }
        }
      }

      visuals {
        scatter_plot_visual {
          visual_id = "events-scatter"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "War Events Plotted Against Brent Price"
            }
          }
          chart_configuration {
            field_wells {
              scatter_plot_categorically_aggregated_field_wells {
                x_axis {
                  numerical_measure_field {
                    field_id = "war-day-x"
                    column {
                      data_set_identifier = "KeyEventsTimeline"
                      column_name         = "war_day"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                y_axis {
                  numerical_measure_field {
                    field_id = "brent-y"
                    column {
                      data_set_identifier = "KeyEventsTimeline"
                      column_name         = "brent_price_that_day"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "AVERAGE"
                    }
                  }
                }
                category {
                  categorical_dimension_field {
                    field_id = "category-color"
                    column {
                      data_set_identifier = "KeyEventsTimeline"
                      column_name         = "category"
                    }
                  }
                }
              }
            }
            legend {
              position   = "RIGHT"
              visibility = "VISIBLE"
            }
          }
        }
      }

      visuals {
        table_visual {
          visual_id = "events-table"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Event Timeline with Brent Price"
            }
          }
          chart_configuration {
            field_wells {
              table_unaggregated_field_wells {
                values {
                  field_id = "tbl-war-day"
                  column {
                    data_set_identifier = "KeyEventsTimeline"
                    column_name         = "war_day"
                  }
                }
                values {
                  field_id = "tbl-date"
                  column {
                    data_set_identifier = "KeyEventsTimeline"
                    column_name         = "date"
                  }
                }
                values {
                  field_id = "tbl-event"
                  column {
                    data_set_identifier = "KeyEventsTimeline"
                    column_name         = "event_title"
                  }
                }
                values {
                  field_id = "tbl-category"
                  column {
                    data_set_identifier = "KeyEventsTimeline"
                    column_name         = "category"
                  }
                }
                values {
                  field_id = "tbl-brent"
                  column {
                    data_set_identifier = "KeyEventsTimeline"
                    column_name         = "brent_price_that_day"
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  permissions {
    actions = [
      "quicksight:RestoreAnalysis",
      "quicksight:UpdateAnalysisPermissions",
      "quicksight:DeleteAnalysis",
      "quicksight:DescribeAnalysisPermissions",
      "quicksight:QueryAnalysis",
      "quicksight:DescribeAnalysis",
      "quicksight:UpdateAnalysis"
    ]
    principal = local.quicksight_user_principal
  }

  depends_on = [
    aws_quicksight_data_set.oil_prices,
    aws_quicksight_data_set.gas_prices,
    aws_quicksight_data_set.key_events
  ]
}

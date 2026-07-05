resource "aws_athena_workgroup" "oil_workgroup" {
  name          = "${var.project_name}-workgroup"
  description   = "Athena workgroup for Iran War Oil Shock 2026 analysis"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.athena_results_bucket_name}/query-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_athena_named_query" "brent_daily_trend" {
  name        = "01-brent-daily-trend"
  workgroup   = aws_athena_workgroup.oil_workgroup.id
  database    = var.database_name
  description = "Daily Brent, WTI and Dubai prices with % change vs pre-war baseline"
  query       = <<-SQL
    SELECT
      "date",
      war_day,
      phase,
      brent_usd_barrel,
      wti_usd_barrel,
      dubai_usd_barrel,
      brent_vs_prewar_pct,
      key_event
    FROM iran_war_oil_prices_daily_2026
    ORDER BY "date";
  SQL
}

resource "aws_athena_named_query" "us_gas_impact" {
  name        = "02-us-gas-price-impact"
  workgroup   = aws_athena_workgroup.oil_workgroup.id
  database    = var.database_name
  description = "US national gas and diesel average prices over time"
  query       = <<-SQL
    SELECT
      "date",
      war_day,
      us_gas_avg_gallon,
      us_diesel_avg_gallon,
      gas_vs_prewar_pct,
      gas_change_from_prewar_dollars,
      strait_hormuz_daily_ships,
      iran_production_mbpd
    FROM iran_war_oil_prices_daily_2026
    ORDER BY "date";
  SQL
}

resource "aws_athena_named_query" "gas_price_by_state" {
  name        = "03-gas-price-by-state"
  workgroup   = aws_athena_workgroup.oil_workgroup.id
  database    = var.database_name
  description = "Retail gas prices per US state on March 19 2026 vs pre-war baseline"
  query       = <<-SQL
    SELECT
      state,
      region,
      gas_price_jan08_2026    AS price_pre_tensions,
      gas_price_prewar_feb27  AS price_day_before_war,
      gas_price_mar19_2026    AS price_war_day_20,
      price_increase_since_war,
      pct_increase_since_war,
      price_vs_national_avg
    FROM iran_war_gas_prices_by_state
    ORDER BY gas_price_mar19_2026 DESC;
  SQL
}

resource "aws_athena_named_query" "regional_gas_summary" {
  name        = "04-regional-gas-summary"
  workgroup   = aws_athena_workgroup.oil_workgroup.id
  database    = var.database_name
  description = "Average gas price increase by US region"
  query       = <<-SQL
    SELECT
      region,
      COUNT(*)                                    AS states,
      ROUND(AVG(gas_price_mar19_2026), 3)         AS avg_current_price,
      ROUND(AVG(gas_price_prewar_feb27), 3)       AS avg_prewar_price,
      ROUND(AVG(price_increase_since_war), 3)     AS avg_dollar_increase,
      ROUND(AVG(pct_increase_since_war), 1)       AS avg_pct_increase
    FROM iran_war_gas_prices_by_state
    GROUP BY region
    ORDER BY avg_current_price DESC;
  SQL
}

resource "aws_athena_named_query" "key_events_with_price" {
  name        = "05-key-events-price-correlation"
  workgroup   = aws_athena_workgroup.oil_workgroup.id
  database    = var.database_name
  description = "Key war events joined with the Brent price on that day"
  query       = <<-SQL
    SELECT
      e."date",
      e.war_day,
      e.category,
      e.event_title,
      e.brent_price_that_day,
      o.us_gas_avg_gallon,
      o.strait_hormuz_daily_ships,
      e.description
    FROM iran_war_key_events_timeline e
    LEFT JOIN iran_war_oil_prices_daily_2026 o
      ON e."date" = o."date"
    ORDER BY e.war_day;
  SQL
}

resource "aws_athena_named_query" "hormuz_closure_impact" {
  name        = "06-hormuz-closure-impact"
  workgroup   = aws_athena_workgroup.oil_workgroup.id
  database    = var.database_name
  description = "Brent price vs Strait of Hormuz ship traffic over time"
  query       = <<-SQL
    SELECT
      "date",
      war_day,
      brent_usd_barrel,
      strait_hormuz_daily_ships,
      iran_production_mbpd,
      brent_vs_prewar_pct
    FROM iran_war_oil_prices_daily_2026
    ORDER BY "date";
  SQL
}

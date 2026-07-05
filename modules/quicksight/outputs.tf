output "data_source_arn" {
  value = aws_quicksight_data_source.athena.arn
}

output "dashboard_id" {
  value = aws_quicksight_dashboard.oil_shock.dashboard_id
}

output "dashboard_url" {
  value = "https://${var.aws_region}.quicksight.aws.amazon.com/sn/dashboards/${aws_quicksight_dashboard.oil_shock.dashboard_id}"
}

output "analysis_id" {
  value = aws_quicksight_analysis.oil_shock.analysis_id
}

output "analysis_url" {
  value = "https://${var.aws_region}.quicksight.aws.amazon.com/sn/analyses/${aws_quicksight_analysis.oil_shock.analysis_id}"
}

output "dataset_ids" {
  value = {
    oil_prices  = aws_quicksight_data_set.oil_prices.data_set_id
    gas_prices  = aws_quicksight_data_set.gas_prices.data_set_id
    key_events  = aws_quicksight_data_set.key_events.data_set_id
  }
}

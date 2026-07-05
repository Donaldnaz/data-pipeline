output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}

output "glue_role_name" {
  value = aws_iam_role.glue_role.name
}

output "quicksight_role_arn" {
  value = aws_iam_role.quicksight_role.arn
}

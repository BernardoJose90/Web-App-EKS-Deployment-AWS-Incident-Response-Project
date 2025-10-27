output "table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
}

################################################################################
# Application
################################################################################

output "arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = try(aws_emrserverless_application.this[0].arn, null)
}

output "id" {
  description = "ID of the application"
  value       = try(aws_emrserverless_application.this[0].id, null)
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

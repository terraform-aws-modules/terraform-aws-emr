################################################################################
# Studio
################################################################################

output "arn" {
  description = "ARN of the studio"
  value       = try(aws_emr_studio.this[0].arn, null)
}

output "url" {
  description = "The unique access URL of the Amazon EMR Studio"
  value       = try(aws_emr_studio.this[0].url, null)
}

################################################################################
# Service IAM Role
################################################################################

output "service_iam_role_name" {
  description = "Service IAM role name"
  value       = try(aws_iam_role.service[0].name, null)
}

output "service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = try(aws_iam_role.service[0].arn, null)
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = try(aws_iam_role.service[0].unique_id, null)
}

################################################################################
# Service IAM Role Policy
################################################################################

output "service_iam_role_policy_arn" {
  description = "Service IAM role policy ARN"
  value       = try(aws_iam_policy.service[0].arn, null)
}

output "service_iam_role_policy_id" {
  description = "Service IAM role policy ID"
  value       = try(aws_iam_policy.service[0].id, null)
}

output "service_iam_role_policy_name" {
  description = "The name of the service role policy"
  value       = try(aws_iam_policy.service[0].name, null)
}

################################################################################
# User IAM Role
################################################################################

output "user_iam_role_name" {
  description = "User IAM role name"
  value       = try(aws_iam_role.user[0].name, null)
}

output "user_iam_role_arn" {
  description = "User IAM role ARN"
  value       = try(aws_iam_role.user[0].arn, null)
}

output "user_iam_role_unique_id" {
  description = "Stable and unique string identifying the user IAM role"
  value       = try(aws_iam_role.user[0].unique_id, null)
}

################################################################################
# User IAM Role Policy
################################################################################

output "user_iam_role_policy_arn" {
  description = "User IAM role policy ARN"
  value       = try(aws_iam_policy.user[0].arn, null)
}

output "user_iam_role_policy_id" {
  description = "User IAM role policy ID"
  value       = try(aws_iam_policy.user[0].id, null)
}

output "user_iam_role_policy_name" {
  description = "The name of the user role policy"
  value       = try(aws_iam_policy.user[0].name, null)
}

################################################################################
# Engine Security Group
################################################################################

output "engine_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the engine security group"
  value       = try(aws_security_group.engine[0].arn, null)
}

output "engine_security_group_id" {
  description = "ID of the engine security group"
  value       = try(aws_security_group.engine[0].id, null)
}

################################################################################
# Workspace Security Group
################################################################################

output "workspace_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the workspace security group"
  value       = try(aws_security_group.workspace[0].arn, null)
}

output "workspace_security_group_id" {
  description = "ID of the workspace security group"
  value       = try(aws_security_group.workspace[0].id, null)
}

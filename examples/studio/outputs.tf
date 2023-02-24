################################################################################
# Complete
################################################################################

output "complete_arn" {
  description = "ARN of the studio"
  value       = module.emr_studio_complete.arn
}

output "complete_url" {
  description = "The unique access URL of the Amazon EMR Studio"
  value       = module.emr_studio_complete.url
}

output "complete_service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.emr_studio_complete.service_iam_role_name
}

output "complete_service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.emr_studio_complete.service_iam_role_arn
}

output "complete_service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.emr_studio_complete.service_iam_role_unique_id
}

output "complete_service_iam_role_policy_arn" {
  description = "Service IAM role policy ARN"
  value       = module.emr_studio_complete.service_iam_role_policy_arn
}

output "complete_service_iam_role_policy_id" {
  description = "Service IAM role policy ID"
  value       = module.emr_studio_complete.service_iam_role_policy_id
}

output "complete_service_iam_role_policy_name" {
  description = "The name of the service role policy"
  value       = module.emr_studio_complete.service_iam_role_policy_name
}

output "complete_user_iam_role_name" {
  description = "User IAM role name"
  value       = module.emr_studio_complete.user_iam_role_name
}

output "complete_user_iam_role_arn" {
  description = "User IAM role ARN"
  value       = module.emr_studio_complete.user_iam_role_arn
}

output "complete_user_iam_role_unique_id" {
  description = "Stable and unique string identifying the user IAM role"
  value       = module.emr_studio_complete.user_iam_role_unique_id
}

output "complete_user_iam_role_policy_arn" {
  description = "User IAM role policy ARN"
  value       = module.emr_studio_complete.user_iam_role_policy_arn
}

output "complete_user_iam_role_policy_id" {
  description = "User IAM role policy ID"
  value       = module.emr_studio_complete.user_iam_role_policy_id
}

output "complete_user_iam_role_policy_name" {
  description = "The name of the user role policy"
  value       = module.emr_studio_complete.user_iam_role_policy_name
}

output "complete_engine_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the engine security group"
  value       = module.emr_studio_complete.engine_security_group_arn
}

output "complete_engine_security_group_id" {
  description = "ID of the engine security group"
  value       = module.emr_studio_complete.engine_security_group_id
}

output "complete_workspace_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the workspace security group"
  value       = module.emr_studio_complete.workspace_security_group_arn
}

output "complete_workspace_security_group_id" {
  description = "ID of the workspace security group"
  value       = module.emr_studio_complete.workspace_security_group_id
}

################################################################################
# SSO
################################################################################

output "sso_arn" {
  description = "ARN of the studio"
  value       = module.emr_studio_sso.arn
}

output "sso_url" {
  description = "The unique access URL of the Amazon EMR Studio"
  value       = module.emr_studio_sso.url
}

output "sso_service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.emr_studio_sso.service_iam_role_name
}

output "sso_service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.emr_studio_sso.service_iam_role_arn
}

output "sso_service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.emr_studio_sso.service_iam_role_unique_id
}

output "sso_service_iam_role_policy_arn" {
  description = "Service IAM role policy ARN"
  value       = module.emr_studio_sso.service_iam_role_policy_arn
}

output "sso_service_iam_role_policy_id" {
  description = "Service IAM role policy ID"
  value       = module.emr_studio_sso.service_iam_role_policy_id
}

output "sso_service_iam_role_policy_name" {
  description = "The name of the service role policy"
  value       = module.emr_studio_sso.service_iam_role_policy_name
}

output "sso_user_iam_role_name" {
  description = "User IAM role name"
  value       = module.emr_studio_sso.user_iam_role_name
}

output "sso_user_iam_role_arn" {
  description = "User IAM role ARN"
  value       = module.emr_studio_sso.user_iam_role_arn
}

output "sso_user_iam_role_unique_id" {
  description = "Stable and unique string identifying the user IAM role"
  value       = module.emr_studio_sso.user_iam_role_unique_id
}

output "sso_user_iam_role_policy_arn" {
  description = "User IAM role policy ARN"
  value       = module.emr_studio_sso.user_iam_role_policy_arn
}

output "sso_user_iam_role_policy_id" {
  description = "User IAM role policy ID"
  value       = module.emr_studio_sso.user_iam_role_policy_id
}

output "sso_user_iam_role_policy_name" {
  description = "The name of the user role policy"
  value       = module.emr_studio_sso.user_iam_role_policy_name
}

output "sso_engine_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the engine security group"
  value       = module.emr_studio_sso.engine_security_group_arn
}

output "sso_engine_security_group_id" {
  description = "ID of the engine security group"
  value       = module.emr_studio_sso.engine_security_group_id
}

output "sso_workspace_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the workspace security group"
  value       = module.emr_studio_sso.workspace_security_group_arn
}

output "sso_workspace_security_group_id" {
  description = "ID of the workspace security group"
  value       = module.emr_studio_sso.workspace_security_group_id
}

################################################################################
# IAM
################################################################################

output "iam_arn" {
  description = "ARN of the studio"
  value       = module.emr_studio_iam.arn
}

output "iam_url" {
  description = "The unique access URL of the Amazon EMR Studio"
  value       = module.emr_studio_iam.url
}

output "iam_service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.emr_studio_iam.service_iam_role_name
}

output "iam_service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.emr_studio_iam.service_iam_role_arn
}

output "iam_service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.emr_studio_iam.service_iam_role_unique_id
}

output "iam_service_iam_role_policy_arn" {
  description = "Service IAM role policy ARN"
  value       = module.emr_studio_iam.service_iam_role_policy_arn
}

output "iam_service_iam_role_policy_id" {
  description = "Service IAM role policy ID"
  value       = module.emr_studio_iam.service_iam_role_policy_id
}

output "iam_service_iam_role_policy_name" {
  description = "The name of the service role policy"
  value       = module.emr_studio_iam.service_iam_role_policy_name
}

output "iam_user_iam_role_name" {
  description = "User IAM role name"
  value       = module.emr_studio_iam.user_iam_role_name
}

output "iam_user_iam_role_arn" {
  description = "User IAM role ARN"
  value       = module.emr_studio_iam.user_iam_role_arn
}

output "iam_user_iam_role_unique_id" {
  description = "Stable and unique string identifying the user IAM role"
  value       = module.emr_studio_iam.user_iam_role_unique_id
}

output "iam_user_iam_role_policy_arn" {
  description = "User IAM role policy ARN"
  value       = module.emr_studio_iam.user_iam_role_policy_arn
}

output "iam_user_iam_role_policy_id" {
  description = "User IAM role policy ID"
  value       = module.emr_studio_iam.user_iam_role_policy_id
}

output "iam_user_iam_role_policy_name" {
  description = "The name of the user role policy"
  value       = module.emr_studio_iam.user_iam_role_policy_name
}

output "iam_engine_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the engine security group"
  value       = module.emr_studio_iam.engine_security_group_arn
}

output "iam_engine_security_group_id" {
  description = "ID of the engine security group"
  value       = module.emr_studio_iam.engine_security_group_id
}

output "iam_workspace_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the workspace security group"
  value       = module.emr_studio_iam.workspace_security_group_arn
}

output "iam_workspace_security_group_id" {
  description = "ID of the workspace security group"
  value       = module.emr_studio_iam.workspace_security_group_id
}

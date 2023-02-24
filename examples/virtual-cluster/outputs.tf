
################################################################################
# Complete
################################################################################

output "complete_job_execution_role_name" {
  description = "IAM role name of the job execution role"
  value       = module.complete.job_execution_role_name
}

output "complete_job_execution_role_arn" {
  description = "IAM role ARN of the job execution role"
  value       = module.complete.job_execution_role_arn
}

output "complete_job_execution_role_unique_id" {
  description = "Stable and unique string identifying the job execution IAM role"
  value       = module.complete.job_execution_role_unique_id
}

output "complete_virtual_cluster_arn" {
  description = "ARN of the EMR virtual cluster"
  value       = module.complete.virtual_cluster_arn
}

output "complete_virtual_cluster_id" {
  description = "ID of the EMR virtual cluster"
  value       = module.complete.virtual_cluster_id
}

output "complete_cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.complete.cloudwatch_log_group_name
}

output "complete_cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.complete.cloudwatch_log_group_arn
}

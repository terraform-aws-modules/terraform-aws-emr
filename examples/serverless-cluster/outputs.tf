################################################################################
# Spark
################################################################################

output "spark_arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = module.emr_serverless_spark.arn
}

output "spark_id" {
  description = "ID of the application"
  value       = module.emr_serverless_spark.id
}

output "spark_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.emr_serverless_spark.security_group_arn
}

output "spark_security_group_id" {
  description = "ID of the security group"
  value       = module.emr_serverless_spark.security_group_id
}

################################################################################
# Hive
################################################################################

output "hive_arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = module.emr_serverless_hive.arn
}

output "hive_id" {
  description = "ID of the application"
  value       = module.emr_serverless_hive.id
}

output "hive_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.emr_serverless_hive.security_group_arn
}

output "hive_security_group_id" {
  description = "ID of the security group"
  value       = module.emr_serverless_hive.security_group_id
}

################################################################################
# Disabled
################################################################################

output "disabled_arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = module.emr_serverless_disabled.arn
}

output "disabled_id" {
  description = "ID of the application"
  value       = module.emr_serverless_disabled.id
}

output "disabled_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.emr_serverless_disabled.security_group_arn
}

output "disabled_security_group_id" {
  description = "ID of the security group"
  value       = module.emr_serverless_disabled.security_group_id
}

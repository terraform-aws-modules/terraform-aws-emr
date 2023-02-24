################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The ARN of the cluster"
  value       = try(aws_emr_cluster.this[0].arn, null)
}

output "cluster_id" {
  description = "The ID of the cluster"
  value       = try(aws_emr_cluster.this[0].id, null)
}

output "cluster_core_instance_group_id" {
  description = "Core node type Instance Group ID, if using Instance Group for this node type"
  value       = try(aws_emr_cluster.this[0].core_instance_group[0].id, null)
}

output "cluster_master_instance_group_id" {
  description = "Master node type Instance Group ID, if using Instance Group for this node type"
  value       = try(aws_emr_cluster.this[0].master_instance_group[0].id, null)
}

output "cluster_master_public_dns" {
  description = "The DNS name of the master node. If the cluster is on a private subnet, this is the private DNS name. On a public subnet, this is the public DNS name"
  value       = try(aws_emr_cluster.this[0].master_public_dns, null)
}

################################################################################
# Security Configuration
################################################################################

output "security_configuration_id" {
  description = "The ID of the security configuration"
  value       = try(aws_emr_security_configuration.this[0].id, null)
}

output "security_configuration_name" {
  description = "The name of the security configuration"
  value       = try(aws_emr_security_configuration.this[0].name, null)
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
  value       = try(aws_iam_role.service[0].arn, var.service_iam_role_arn)
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = try(aws_iam_role.service[0].unique_id, null)
}

################################################################################
# Autoscaling IAM Role
################################################################################

output "autoscaling_iam_role_name" {
  description = "Autoscaling IAM role name"
  value       = try(aws_iam_role.autoscaling[0].name, null)
}

output "autoscaling_iam_role_arn" {
  description = "Autoscaling IAM role ARN"
  value       = try(aws_iam_role.autoscaling[0].arn, var.autoscaling_iam_role_arn)
}

output "autoscaling_iam_role_unique_id" {
  description = "Stable and unique string identifying the autoscaling IAM role"
  value       = try(aws_iam_role.autoscaling[0].unique_id, null)
}

################################################################################
# Instance Profile
################################################################################

output "iam_instance_profile_iam_role_name" {
  description = "Instance profile IAM role name"
  value       = try(aws_iam_role.instance_profile[0].name, null)
}

output "iam_instance_profile_iam_role_arn" {
  description = "Instance profile IAM role ARN"
  value       = try(aws_iam_role.instance_profile[0].arn, null)
}

output "iam_instance_profile_iam_role_unique_id" {
  description = "Stable and unique string identifying the instance profile IAM role"
  value       = try(aws_iam_role.instance_profile[0].unique_id, null)
}

output "iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.this[0].id, null)
}

output "iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].unique_id, null)
}

################################################################################
# Managed Master Security Group
################################################################################

output "managed_master_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the managed master security group"
  value       = try(aws_security_group.master[0].arn, null)
}

output "managed_master_security_group_id" {
  description = "ID of the managed master security group"
  value       = try(aws_security_group.master[0].id, null)
}

################################################################################
# Managed Slave Security Group
################################################################################

output "managed_slave_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the managed slave security group"
  value       = try(aws_security_group.slave[0].arn, null)
}

output "managed_slave_security_group_id" {
  description = "ID of the managed slave security group"
  value       = try(aws_security_group.slave[0].id, null)
}

################################################################################
# Managed Service Access Security Group
################################################################################

output "managed_service_access_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the managed service access security group"
  value       = try(aws_security_group.service[0].arn, null)
}

output "managed_service_access_security_group_id" {
  description = "ID of the managed service access security group"
  value       = try(aws_security_group.service[0].id, null)
}

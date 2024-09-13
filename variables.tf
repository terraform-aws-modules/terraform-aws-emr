variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "additional_info" {
  description = "JSON string for selecting additional features such as adding proxy information. Note: Currently there is no API to retrieve the value of this argument after EMR cluster creation from provider, therefore Terraform cannot detect drift from the actual EMR cluster if its value is changed outside Terraform"
  type        = string
  default     = null
}

variable "applications" {
  description = "A case-insensitive list of applications for Amazon EMR to install and configure when launching the cluster"
  type        = list(string)
  default     = []
}

variable "auto_termination_policy" {
  description = "An auto-termination policy for an Amazon EMR cluster. An auto-termination policy defines the amount of idle time in seconds after which a cluster automatically terminates"
  type        = any
  default     = {}
}

variable "bootstrap_action" {
  description = "Ordered list of bootstrap actions that will be run before Hadoop is started on the cluster nodes"
  type        = any
  default     = {}
}

variable "configurations" {
  description = "List of configurations supplied for the EMR cluster you are creating. Supply a configuration object for applications to override their default configuration"
  type        = string
  default     = null
}

variable "configurations_json" {
  description = "JSON string for supplying list of configurations for the EMR cluster"
  type        = string
  default     = null
}

variable "core_instance_fleet" {
  description = "Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the core node type. Cannot be specified if any `core_instance_group` configuration blocks are set"
  type        = any
  default     = {}
}

variable "core_instance_group" {
  description = "Configuration block to use an [Instance Group] for the core node type"
  type        = any
  default     = {}
}

variable "custom_ami_id" {
  description = "Custom Amazon Linux AMI for the cluster (instead of an EMR-owned AMI). Available in Amazon EMR version 5.7.0 and later"
  type        = string
  default     = null
}

variable "ebs_root_volume_size" {
  description = "Size in GiB of the EBS root device volume of the Linux AMI that is used for each EC2 instance. Available in Amazon EMR version 4.x and later"
  type        = number
  default     = null
}

variable "ec2_attributes" {
  description = "Attributes for the EC2 instances running the job flow"
  type        = any
  default     = {}
}

variable "keep_job_flow_alive_when_no_steps" {
  description = "Switch on/off run cluster with no steps or when all steps are complete (default is on)"
  type        = bool
  default     = null
}

variable "kerberos_attributes" {
  description = "Kerberos configuration for the cluster"
  type        = any
  default     = {}
}

variable "list_steps_states" {
  description = "List of [step states](https://docs.aws.amazon.com/emr/latest/APIReference/API_StepStatus.html) used to filter returned steps"
  type        = list(string)
  default     = []
}

variable "log_encryption_kms_key_id" {
  description = "AWS KMS customer master key (CMK) key ID or arn used for encrypting log files. This attribute is only available with EMR version 5.30.0 and later, excluding EMR 6.0.0"
  type        = string
  default     = null
}

variable "log_uri" {
  description = "S3 bucket to write the log files of the job flow. If a value is not provided, logs are not created"
  type        = string
  default     = null
}

variable "master_instance_fleet" {
  description = "Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the master node type. Cannot be specified if any `master_instance_group` configuration blocks are set"
  type        = any
  default     = {}
}

variable "master_instance_group" {
  description = "Configuration block to use an [Instance Group](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-group-configuration.html#emr-plan-instance-groups) for the [master node type](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html#emr-plan-master)"
  type        = any
  default     = {}
}

variable "name" {
  description = "Name of the job flow"
  type        = string
  default     = ""
}

variable "placement_group_config" {
  description = "The specified placement group configuration"
  type        = any
  default     = {}
}

variable "release_label" {
  description = "Release label for the Amazon EMR release"
  type        = string
  default     = null
}

variable "release_label_filters" {
  description = "Map of release label filters use to lookup a release label"
  type        = any
  default = {
    default = {
      # application = "spark@3"
      prefix = "emr-6"
    }
  }
}

variable "scale_down_behavior" {
  description = "Way that individual Amazon EC2 instances terminate when an automatic scale-in activity occurs or an instance group is resized"
  type        = string
  default     = "TERMINATE_AT_TASK_COMPLETION"
}

variable "step" {
  description = "Steps to run when creating the cluster"
  type        = any
  default     = {}
}

variable "step_concurrency_level" {
  description = "Number of steps that can be executed concurrently. You can specify a maximum of 256 steps. Only valid for EMR clusters with `release_label` 5.28.0 or greater (default is 1)"
  type        = number
  default     = null
}

variable "termination_protection" {
  description = "Switch on/off termination protection (default is `false`, except when using multiple master nodes). Before attempting to destroy the resource when termination protection is enabled, this configuration must be applied with its value set to `false`"
  type        = bool
  default     = null
}

variable "unhealthy_node_replacement" {
  description = "Whether whether Amazon EMR should gracefully replace core nodes that have degraded within the cluster. Default value is `false`"
  type        = bool
  default     = null
}

variable "visible_to_all_users" {
  description = "Whether the job flow is visible to all IAM users of the AWS account associated with the job flow. Default value is `true`"
  type        = bool
  default     = null
}

################################################################################
# Task Instance Fleet
# Ref: https://github.com/hashicorp/terraform-provider-aws/issues/29668
################################################################################

variable "task_instance_fleet" {
  description = "Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the task node type. Cannot be specified if any `task_instance_group` configuration blocks are set"
  type        = any
  default     = {}
}

################################################################################
# Task Instance Group
# Ref: https://github.com/hashicorp/terraform-provider-aws/issues/29668
################################################################################

variable "task_instance_group" {
  description = "Configuration block to use an [Instance Group](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-group-configuration.html#emr-plan-instance-groups) for the [task node type](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html#emr-plan-master)"
  type        = any
  default     = {}
}

################################################################################
# Managed Scaling Policy
################################################################################

variable "managed_scaling_policy" {
  description = "Compute limit configuration for a [Managed Scaling Policy](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-scaling.html)"
  type        = any
  default     = {}
}

################################################################################
# Security Configuration
################################################################################

variable "create_security_configuration" {
  description = "Determines whether a security configuration is created"
  type        = bool
  default     = false
}

variable "security_configuration_name" {
  description = "Name of the security configuration to create, or attach if `create_security_configuration` is `false`. Only valid for EMR clusters with `release_label` 4.8.0 or greater"
  type        = string
  default     = null
}

variable "security_configuration_use_name_prefix" {
  description = "Determines whether `security_configuration_name` is used as a prefix"
  type        = bool
  default     = true
}

variable "security_configuration" {
  description = "Security configuration to create, or attach if `create_security_configuration` is `false`. Only valid for EMR clusters with `release_label` 4.8.0 or greater"
  type        = string
  default     = null
}

################################################################################
# Common IAM Role
################################################################################

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Service IAM Role
################################################################################

variable "create_service_iam_role" {
  description = "Determines whether the service IAM role should be created"
  type        = bool
  default     = true
}

variable "service_iam_role_arn" {
  description = "The ARN of an existing IAM role to use for the service"
  type        = string
  default     = null
}

variable "service_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "service_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "service_iam_role_policies" {
  description = "Map of IAM policies to attach to the service role"
  type        = map(string)
  default     = { AmazonEMRServicePolicy_v2 = "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2" }
}

variable "service_pass_role_policy_name" {
  description = "Name to use on IAM policy created"
  type        = string
  default     = null
}

variable "service_pass_role_policy_description" {
  description = "Description of the policy"
  type        = string
  default     = null
}

################################################################################
# Autoscaling IAM Role
################################################################################

variable "create_autoscaling_iam_role" {
  description = "Determines whether the autoscaling IAM role should be created"
  type        = bool
  default     = true
}

variable "autoscaling_iam_role_arn" {
  description = "The ARN of an existing IAM role to use for autoscaling"
  type        = string
  default     = null
}

variable "autoscaling_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "autoscaling_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

################################################################################
# Instance Profile
################################################################################

variable "create_iam_instance_profile" {
  description = "Determines whether the EC2 IAM role/instance profile should be created"
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Name to use on EC2 IAM role/instance profile created"
  type        = string
  default     = null
}

variable "iam_instance_profile_description" {
  description = "Description of the EC2 IAM role/instance profile"
  type        = string
  default     = null
}

variable "iam_instance_profile_policies" {
  description = "Map of IAM policies to attach to the EC2 IAM role/instance profile"
  type        = map(string)
  default     = { AmazonElasticMapReduceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role" }
}

variable "iam_instance_profile_role_arn" {
  description = "The role associated with the ec2 instance profile if specifying a custom instance profile"
  type        = string
  default     = null
}

################################################################################
# Managed Security Group
################################################################################

variable "create_managed_security_groups" {
  description = "Determines whether managed security groups are created"
  type        = bool
  default     = true
}

variable "managed_security_group_name" {
  description = "Name to use on manged security group created. Note - `-master`, `-slave`, and `-service` will be appended to this name to distinguish"
  type        = string
  default     = null
}

variable "managed_security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "managed_security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the Amazon Virtual Private Cloud (Amazon VPC) where the security groups will be created"
  type        = string
  default     = ""
}

################################################################################
# Managed Master Security Group
################################################################################

variable "master_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Managed master security group"
}

variable "master_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default = {
    "default" = {
      description      = "Allow all egress traffic"
      type             = "egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

################################################################################
# Managed Slave Security Group
################################################################################

variable "slave_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Managed slave security group"
}

variable "slave_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default = {
    "default" = {
      description      = "Allow all egress traffic"
      type             = "egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

################################################################################
# Managed Service Access Security Group
################################################################################

variable "is_private_cluster" {
  description = "Identifies whether the cluster is created in a private subnet"
  type        = bool
  default     = true
}

variable "service_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Managed service access security group"
}

variable "service_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}

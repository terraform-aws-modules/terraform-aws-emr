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
# Studio
################################################################################

variable "auth_mode" {
  description = "Specifies whether the Studio authenticates users using IAM or Amazon Web Services SSO. Valid values are `SSO` or `IAM`"
  type        = string
  default     = "IAM"
}

variable "default_s3_location" {
  description = "The Amazon S3 location to back up Amazon EMR Studio Workspaces and notebook files"
  type        = string
  default     = ""
}

variable "description" {
  description = "A detailed description of the Amazon EMR Studio"
  type        = string
  default     = null
}

variable "idp_auth_url" {
  description = "The authentication endpoint of your identity provider (IdP). Specify this value when you use IAM authentication and want to let federated users log in to a Studio with the Studio URL and credentials from your IdP"
  type        = string
  default     = null
}

variable "idp_relay_state_parameter_name" {
  description = "The name that your identity provider (IdP) uses for its RelayState parameter. For example, RelayState or TargetSource"
  type        = string
  default     = null
}

variable "name" {
  description = "A descriptive name for the Amazon EMR Studio"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate with the Amazon EMR Studio. A Studio can have a maximum of 5 subnets. The subnets must belong to the VPC specified by `vpc_id`"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The ID of the Amazon Virtual Private Cloud (Amazon VPC) to associate with the Studio"
  type        = string
  default     = ""
}

################################################################################
# Studio Session Mapping
################################################################################

variable "session_mappings" {
  description = "A map of session mapping definitions to apply to the Studio"
  type        = any
  default     = {}
}

################################################################################
# Service IAM Role
################################################################################

variable "create_service_role" {
  description = "Determines whether the service IAM role should be created"
  type        = bool
  default     = true
}

variable "service_role_arn" {
  description = "The ARN of an existing IAM role to use for the service"
  type        = string
  default     = null
}

variable "service_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "service_role_use_name_prefix" {
  description = "Determines whether the IAM role name is used as a prefix"
  type        = bool
  default     = true
}

variable "service_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}
variable "service_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "service_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "service_role_policies" {
  description = "Map of IAM policies to attach to the service role"
  type        = map(string)
  default     = {}
}

variable "service_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Service IAM Role Policy
################################################################################

variable "create_service_role_policy" {
  description = "Determines whether the service IAM role policy should be created"
  type        = bool
  default     = true
}

variable "service_role_secrets_manager_arns" {
  description = "A list of Amazon Web Services Secrets Manager secret ARNs to allow use of Git credentials stored in AWS Secrets Manager to link Git repositories to a Workspace"
  type        = list(string)
  default     = []
}

variable "service_role_s3_bucket_arns" {
  description = "A list of Amazon S3 bucket ARNs to allow permission to read/write from the Amazon EMR Studio"
  type        = list(string)
  default     = []
}

variable "service_role_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
}

################################################################################
# User IAM Role
################################################################################

variable "create_user_role" {
  description = "Determines whether the user IAM role should be created"
  type        = bool
  default     = true
}

variable "user_role_arn" {
  description = "The ARN of an existing IAM role to use for the user"
  type        = string
  default     = null
}

variable "user_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "user_role_use_name_prefix" {
  description = "Determines whether the IAM role name is used as a prefix"
  type        = bool
  default     = true
}

variable "user_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}
variable "user_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "user_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "user_role_policies" {
  description = "Map of IAM policies to attach to the user role"
  type        = map(string)
  default     = {}
}

variable "user_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# User IAM Role Policy
################################################################################

variable "create_user_role_policy" {
  description = "Determines whether the user IAM role policy should be created"
  type        = bool
  default     = true
}

variable "user_role_s3_bucket_arns" {
  description = "A list of Amazon S3 bucket ARNs to allow permission to read/write from the Amazon EMR Studio user role"
  type        = list(string)
  default     = []
}

variable "user_role_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
}

################################################################################
# Security Group
################################################################################

variable "create_security_groups" {
  description = "Determines whether security groups for the EMR Studio engine and workspace are created"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name to use on security group created. Note - `-engine` and `-workspace` will be appended to this name to distinguish"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

################################################################################
# Engine Security Group
################################################################################

variable "engine_security_group_id" {
  description = "The ID of the Amazon EMR Studio Engine security group. The Engine security group allows inbound network traffic from the Workspace security group, and it must be in the same VPC specified by `vpc_id`"
  type        = string
  default     = null
}

variable "engine_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "EMR Studio engine security group"
}

variable "engine_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}

################################################################################
# Workspace Security Group
################################################################################

variable "workspace_security_group_id" {
  description = "The ID of the Amazon EMR Studio Workspace security group. The Workspace security group allows outbound network traffic to resources in the Engine security group, and it must be in the same VPC specified by `vpc_id`"
  type        = string
  default     = null
}

variable "workspace_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "EMR Studio workspace security group"
}

variable "workspace_security_group_rules" {
  description = "Security group rules to add to the security group created. Note - only egress rules are permitted"
  type        = any
  default     = {}
}

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
# Application
################################################################################

variable "architecture" {
  description = "The CPU architecture of an application. Valid values are `ARM64` or `X86_64`. Default value is `X86_64`"
  type        = string
  default     = null
}

variable "auto_start_configuration" {
  description = "The configuration for an application to automatically start on job submission"
  type        = any
  default     = {}
}

variable "auto_stop_configuration" {
  description = "The configuration for an application to automatically stop after a certain amount of time being idle"
  type        = any
  default     = {}
}

variable "image_configuration" {
  description = "The image configuration applied to all worker types"
  type        = any
  default     = {}
}

variable "initial_capacity" {
  description = "The capacity to initialize when the application is created"
  type        = any
  default     = {}
}

variable "maximum_capacity" {
  description = "The maximum capacity to allocate when the application is created. This is cumulative across all workers at any given point in time, not just when an application is created. No new resources will be created once any one of the defined limits is hit"
  type        = any
  default     = {}
}

variable "name" {
  description = "The name of the application"
  type        = string
  default     = ""
}

variable "network_configuration" {
  description = "The network configuration for customer VPC connectivity"
  type        = any
  default     = {}
}

variable "release_label" {
  description = "Release label for the Amazon EMR release"
  type        = string
  default     = null
}

variable "release_label_prefix" {
  description = "Release label prefix used to lookup a release label"
  type        = string
  default     = "emr-6"
}

variable "type" {
  description = "The type of application you want to start, such as `spark` or `hive`. Defaults to `spark`"
  type        = string
  default     = "spark"
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines whether the security group is created"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

variable "security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}

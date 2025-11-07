variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
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
  type = object({
    enabled = optional(bool)
  })
  default = null
}

variable "auto_stop_configuration" {
  description = "The configuration for an application to automatically stop after a certain amount of time being idle"
  type = object({
    enabled              = optional(bool)
    idle_timeout_minutes = optional(number)
  })
  default = null
}

variable "image_configuration" {
  description = "The image configuration applied to all worker types"
  type = object({
    image_uri = string
  })
  default = null
}

variable "initial_capacity" {
  description = "The capacity to initialize when the application is created"
  type = map(object({
    initial_capacity_config = optional(object({
      worker_configuration = optional(object({
        cpu    = string
        disk   = optional(string)
        memory = string
      }))
      worker_count = optional(number, 1)
    }))
    initial_capacity_type = string
  }))
  default = null
}

variable "interactive_configuration" {
  description = "Enables the interactive use cases to use when running an application"
  type = object({
    livy_endpoint_enabled = optional(bool)
    studio_enabled        = optional(bool)
  })
  default = null
}

variable "maximum_capacity" {
  description = "The maximum capacity to allocate when the application is created. This is cumulative across all workers at any given point in time, not just when an application is created. No new resources will be created once any one of the defined limits is hit"
  type = object({
    cpu    = string
    disk   = optional(string)
    memory = string
  })
  default = null
}

variable "name" {
  description = "The name of the application"
  type        = string
  default     = ""
}

variable "network_configuration" {
  description = "The network configuration for customer VPC connectivity"
  type = object({
    security_group_ids = optional(list(string), [])
    subnet_ids         = optional(list(string))
  })
  default = null
}

variable "release_label" {
  description = "Release label for the Amazon EMR release"
  type        = string
  default     = null
}

variable "release_label_filters" {
  description = "Map of release label filters use to lookup a release label"
  type = map(object({
    application = optional(string)
    prefix      = optional(string)
  }))
  default = {
    default = {
      # application = "spark@3"
      prefix = "emr-7"
    }
  }
}

variable "monitoring_configuration" {
  description = "The monitoring configuration for the application"
  type = object({
    cloudwatch_logging_configuration = optional(object({
      enabled                = optional(bool)
      log_group_name         = optional(string)
      log_stream_name_prefix = optional(string)
      encryption_key_arn     = optional(string)
      log_types = optional(list(object({
        name   = string
        values = list(string)
      })))
    }))
    managed_persistence_monitoring_configuration = optional(object({
      enabled            = optional(bool)
      encryption_key_arn = optional(string)
    }))
    prometheus_monitoring_configuration = optional(object({
      remote_write_url = optional(string)
    }))
    s3_monitoring_configuration = optional(object({
      log_uri            = optional(string)
      encryption_key_arn = optional(string)
    }))
  })
  default = null
}

variable "runtime_configuration" {
  description = "The runtime configuration for the application"
  type = list(object({
    classification = string
    properties     = optional(map(string))
  }))
  default = null
}

variable "scheduler_configuration" {
  description = "The scheduler configuration for the application"
  type = object({
    max_concurrent_runs   = optional(number)
    queue_timeout_minutes = optional(number)
  })
  default = null
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

variable "security_group_ingress_rules" {
  description = "Security group ingress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_egress_rules" {
  description = "Security group egress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default = {
    "all-traffic" = {
      description = "Allow all egress traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  nullable = false
}

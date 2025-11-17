data "aws_emr_release_labels" "this" {
  count = var.create && var.release_label_filters != null ? 1 : 0

  region = var.region

  dynamic "filters" {
    for_each = var.release_label_filters

    content {
      application = filters.value.application
      prefix      = filters.value.prefix
    }
  }
}

locals {
  tags = merge(var.tags, { terraform-aws-modules = "emr" })
}

################################################################################
# Application
################################################################################

resource "aws_emrserverless_application" "this" {
  count = var.create ? 1 : 0

  region = var.region

  architecture = var.architecture

  dynamic "auto_start_configuration" {
    for_each = var.auto_start_configuration != null ? [var.auto_start_configuration] : []

    content {
      enabled = auto_start_configuration.value.enabled
    }
  }

  dynamic "auto_stop_configuration" {
    for_each = var.auto_stop_configuration != null ? [var.auto_stop_configuration] : []

    content {
      enabled              = auto_stop_configuration.value.enabled
      idle_timeout_minutes = auto_stop_configuration.value.idle_timeout_minutes
    }
  }

  dynamic "image_configuration" {
    for_each = var.image_configuration != null ? [var.image_configuration] : []

    content {
      image_uri = image_configuration.value.image_uri
    }
  }

  dynamic "initial_capacity" {
    for_each = var.initial_capacity != null ? var.initial_capacity : {}

    content {
      dynamic "initial_capacity_config" {
        for_each = initial_capacity.value.initial_capacity_config != null ? [initial_capacity.value.initial_capacity_config] : []

        content {
          dynamic "worker_configuration" {
            for_each = initial_capacity_config.value.worker_configuration != null ? [initial_capacity_config.value.worker_configuration] : []

            content {
              cpu    = worker_configuration.value.cpu
              disk   = worker_configuration.value.disk
              memory = worker_configuration.value.memory
            }
          }

          worker_count = initial_capacity_config.value.worker_count
        }
      }

      initial_capacity_type = initial_capacity.value.initial_capacity_type
    }
  }

  dynamic "interactive_configuration" {
    for_each = var.interactive_configuration != null ? [var.interactive_configuration] : []

    content {
      livy_endpoint_enabled = interactive_configuration.value.livy_endpoint_enabled
      studio_enabled        = interactive_configuration.value.studio_enabled
    }
  }

  dynamic "maximum_capacity" {
    for_each = var.maximum_capacity != null ? [var.maximum_capacity] : []

    content {
      cpu    = maximum_capacity.value.cpu
      disk   = maximum_capacity.value.disk
      memory = maximum_capacity.value.memory
    }
  }

  name = var.name

  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []

    content {
      security_group_ids = compact(concat(aws_security_group.this[*].id, network_configuration.value.security_group_ids))
      subnet_ids         = network_configuration.value.subnet_ids
    }
  }

  release_label = try(coalesce(var.release_label, element(data.aws_emr_release_labels.this[0].release_labels, 0)))

  dynamic "monitoring_configuration" {
    for_each = var.monitoring_configuration != null ? [var.monitoring_configuration] : []

    content {
      dynamic "cloudwatch_logging_configuration" {
        for_each = monitoring_configuration.value.cloudwatch_logging_configuration != null ? [monitoring_configuration.value.cloudwatch_logging_configuration] : []

        content {
          enabled                = cloudwatch_logging_configuration.value.enabled
          log_group_name         = cloudwatch_logging_configuration.value.log_group_name
          log_stream_name_prefix = cloudwatch_logging_configuration.value.log_stream_name_prefix
          encryption_key_arn     = cloudwatch_logging_configuration.value.encryption_key_arn

          dynamic "log_types" {
            for_each = cloudwatch_logging_configuration.value.log_types != null ? cloudwatch_logging_configuration.value.log_types : []

            content {
              name   = log_types.value.name
              values = log_types.value.values
            }
          }
        }
      }

      dynamic "managed_persistence_monitoring_configuration" {
        for_each = monitoring_configuration.value.managed_persistence_monitoring_configuration != null ? [monitoring_configuration.value.managed_persistence_monitoring_configuration] : []

        content {
          enabled            = managed_persistence_monitoring_configuration.value.enabled
          encryption_key_arn = managed_persistence_monitoring_configuration.value.encryption_key_arn
        }
      }

      dynamic "prometheus_monitoring_configuration" {
        for_each = monitoring_configuration.value.prometheus_monitoring_configuration != null ? [monitoring_configuration.value.prometheus_monitoring_configuration] : []

        content {
          remote_write_url = prometheus_monitoring_configuration.value.remote_write_url
        }
      }

      dynamic "s3_monitoring_configuration" {
        for_each = monitoring_configuration.value.s3_monitoring_configuration != null ? [monitoring_configuration.value.s3_monitoring_configuration] : []

        content {
          log_uri            = s3_monitoring_configuration.value.log_uri
          encryption_key_arn = s3_monitoring_configuration.value.encryption_key_arn
        }
      }
    }
  }

  dynamic "runtime_configuration" {
    for_each = var.runtime_configuration != null ? var.runtime_configuration : []

    content {
      classification = runtime_configuration.value.classification
      properties     = runtime_configuration.value.properties
    }
  }

  dynamic "scheduler_configuration" {
    for_each = var.scheduler_configuration != null ? [var.scheduler_configuration] : []

    content {
      max_concurrent_runs   = scheduler_configuration.value.max_concurrent_runs
      queue_timeout_minutes = scheduler_configuration.value.queue_timeout_minutes
    }
  }

  type = var.type

  tags = local.tags
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = var.create && var.create_security_group && try(var.network_configuration.subnet_ids, null) != null
  security_group_name   = try(coalesce(var.security_group_name, var.name), "")
}

data "aws_subnet" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  id = element(var.network_configuration.subnet_ids, 0)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = data.aws_subnet.this[0].vpc_id

  tags = merge(
    local.tags,
    var.security_group_tags,
    { "Name" = local.security_group_name },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.security_group_ingress_rules != null && local.create_security_group ? var.security_group_ingress_rules : {}

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.security_group_egress_rules != null && local.create_security_group ? var.security_group_egress_rules : {}

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}

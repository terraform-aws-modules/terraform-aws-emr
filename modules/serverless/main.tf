data "aws_emr_release_labels" "this" {
  count = var.create ? 1 : 0

  filters {
    prefix = var.release_label_prefix
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

  architecture = var.architecture

  dynamic "auto_start_configuration" {
    for_each = [var.auto_start_configuration]

    content {
      enabled = try(auto_start_configuration.value.enabled, null)
    }
  }

  dynamic "auto_stop_configuration" {
    for_each = [var.auto_stop_configuration]

    content {
      enabled              = try(auto_stop_configuration.value.enabled, null)
      idle_timeout_minutes = try(auto_stop_configuration.value.idle_timeout_minutes, null)
    }
  }

  dynamic "initial_capacity" {
    for_each = var.initial_capacity

    content {
      dynamic "initial_capacity_config" {
        for_each = try([initial_capacity.value.initial_capacity_config], [])

        content {
          dynamic "worker_configuration" {
            for_each = try([initial_capacity_config.value.worker_configuration], [])

            content {
              cpu    = worker_configuration.value.cpu
              disk   = try(worker_configuration.value.disk, null)
              memory = worker_configuration.value.memory
            }
          }

          worker_count = try(initial_capacity_config.value.worker_count, 1)
        }
      }

      initial_capacity_type = initial_capacity.value.initial_capacity_type
    }
  }

  dynamic "maximum_capacity" {
    for_each = length(var.maximum_capacity) > 0 ? [var.maximum_capacity] : []

    content {
      cpu    = maximum_capacity.value.cpu
      disk   = try(maximum_capacity.value.disk, null)
      memory = maximum_capacity.value.memory
    }
  }

  name = var.name

  dynamic "network_configuration" {
    for_each = length(var.network_configuration) > 0 ? [var.network_configuration] : []

    content {
      security_group_ids = compact(concat([try(aws_security_group.this[0].id, "")], try(network_configuration.value.security_group_ids, [])))
      subnet_ids         = try(network_configuration.value.subnet_ids, null)
    }
  }

  dynamic "image_configuration" {
    for_each = length(var.image_configuration) > 0 ? [var.image_configuration] : []

    content {
      image_uri = image_configuration.value.image_uri
    }
  }

  release_label = try(coalesce(var.release_label, element(data.aws_emr_release_labels.this[0].release_labels, 0)), "")
  type          = var.type

  tags = local.tags
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = var.create && var.create_security_group && length(lookup(var.network_configuration, "subnet_ids", [])) > 0
  security_group_name   = try(coalesce(var.security_group_name, var.name), "")
}

data "aws_subnet" "this" {
  count = local.create_security_group ? 1 : 0

  id = element(var.network_configuration.subnet_ids, 0)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

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

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if local.create_security_group }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = try(each.value.protocol, "tcp")
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = try(each.value.type, "egress")

  # Optional
  description              = lookup(each.value, "description", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

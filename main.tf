data "aws_region" "current" {
  count = var.create ? 1 : 0

  region = var.region
}
data "aws_partition" "current" {
  count = var.create ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.create ? 1 : 0
}

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

  region     = try(data.aws_region.current[0].region, "")
  dns_suffix = try(data.aws_partition.current[0].dns_suffix, "")
  partition  = try(data.aws_partition.current[0].partition, "")
  account_id = try(data.aws_caller_identity.current[0].account_id, "")
}

################################################################################
# Cluster
################################################################################

resource "aws_emr_cluster" "this" {
  count = var.create ? 1 : 0

  additional_info = var.additional_info
  applications    = var.applications

  dynamic "auto_termination_policy" {
    for_each = var.auto_termination_policy != null ? [var.auto_termination_policy] : []

    content {
      idle_timeout = auto_termination_policy.value.idle_timeout
    }
  }

  autoscaling_role = local.create_autoscaling_iam_role ? aws_iam_role.autoscaling[0].arn : var.autoscaling_iam_role_arn

  dynamic "bootstrap_action" {
    for_each = var.bootstrap_action != null ? var.bootstrap_action : []

    content {
      args = bootstrap_action.value.args
      name = bootstrap_action.value.name
      path = bootstrap_action.value.path
    }
  }

  configurations      = var.configurations
  configurations_json = var.configurations_json

  dynamic "core_instance_fleet" {
    for_each = var.core_instance_fleet != null ? [var.core_instance_fleet] : []

    content {
      dynamic "instance_type_configs" {
        for_each = core_instance_fleet.value.instance_type_configs != null ? core_instance_fleet.value.instance_type_configs : []

        content {
          bid_price                                  = instance_type_configs.value.bid_price
          bid_price_as_percentage_of_on_demand_price = instance_type_configs.value.bid_price_as_percentage_of_on_demand_price

          dynamic "configurations" {
            for_each = instance_type_configs.value.configurations != null ? instance_type_configs.value.configurations : []

            content {
              classification = configurations.value.classification
              properties     = configurations.value.properties
            }
          }

          dynamic "ebs_config" {
            for_each = instance_type_configs.value.ebs_config != null ? instance_type_configs.value.ebs_config : []

            content {
              iops                 = ebs_config.value.iops
              size                 = ebs_config.value.size
              type                 = ebs_config.value.type
              volumes_per_instance = ebs_config.value.volumes_per_instance
            }
          }

          instance_type     = instance_type_configs.value.instance_type
          weighted_capacity = instance_type_configs.value.weighted_capacity
        }
      }

      dynamic "launch_specifications" {
        for_each = core_instance_fleet.value.launch_specifications != null ? [core_instance_fleet.value.launch_specifications] : []

        content {
          dynamic "on_demand_specification" {
            for_each = launch_specifications.value.on_demand_specification != null ? [launch_specifications.value.on_demand_specification] : []

            content {
              allocation_strategy = on_demand_specification.value.allocation_strategy
            }
          }

          dynamic "spot_specification" {
            for_each = launch_specifications.value.spot_specification != null ? [launch_specifications.value.spot_specification] : []

            content {
              allocation_strategy      = spot_specification.value.allocation_strategy
              block_duration_minutes   = launch_specifications.value.spot_specification.block_duration_minutes
              timeout_action           = launch_specifications.value.spot_specification.timeout_action
              timeout_duration_minutes = launch_specifications.value.spot_specification.timeout_duration_minutes
            }
          }
        }
      }

      name                      = core_instance_fleet.value.name
      target_on_demand_capacity = core_instance_fleet.value.target_on_demand_capacity
      target_spot_capacity      = core_instance_fleet.value.target_spot_capacity
    }
  }

  dynamic "core_instance_group" {
    for_each = var.core_instance_group != null ? [var.core_instance_group] : []

    content {
      autoscaling_policy = core_instance_group.value.autoscaling_policy
      bid_price          = core_instance_group.value.bid_price

      dynamic "ebs_config" {
        for_each = core_instance_group.value.ebs_config != null ? core_instance_group.value.ebs_config : []

        content {
          iops                 = ebs_config.value.iops
          size                 = ebs_config.value.size
          throughput           = ebs_config.value.throughput
          type                 = ebs_config.value.type
          volumes_per_instance = ebs_config.value.volumes_per_instance
        }
      }

      instance_count = core_instance_group.value.instance_count
      instance_type  = core_instance_group.value.instance_type
      name           = core_instance_group.value.name
    }
  }

  custom_ami_id        = var.custom_ami_id
  ebs_root_volume_size = var.ebs_root_volume_size

  dynamic "ec2_attributes" {
    for_each = length(var.ec2_attributes) > 0 || local.create_managed_security_groups || local.create_iam_instance_profile ? [var.ec2_attributes] : []

    content {
      additional_master_security_groups = ec2_attributes.value.additional_master_security_groups
      additional_slave_security_groups  = ec2_attributes.value.additional_slave_security_groups
      emr_managed_master_security_group = local.create_managed_security_groups ? aws_security_group.master[0].id : ec2_attributes.value.emr_managed_master_security_group
      emr_managed_slave_security_group  = local.create_managed_security_groups ? aws_security_group.slave[0].id : ec2_attributes.value.emr_managed_slave_security_group
      instance_profile                  = local.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : ec2_attributes.value.instance_profile
      key_name                          = ec2_attributes.value.key_name
      service_access_security_group     = local.create_service_security_group ? aws_security_group.service[0].id : ec2_attributes.value.service_access_security_group
      subnet_id                         = ec2_attributes.value.subnet_id
      subnet_ids                        = ec2_attributes.value.subnet_ids
    }
  }

  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps

  dynamic "kerberos_attributes" {
    for_each = var.kerberos_attributes != null ? [var.kerberos_attributes] : []

    content {
      ad_domain_join_password              = kerberos_attributes.value.ad_domain_join_password
      ad_domain_join_user                  = kerberos_attributes.value.ad_domain_join_user
      cross_realm_trust_principal_password = kerberos_attributes.value.cross_realm_trust_principal_password
      kdc_admin_password                   = kerberos_attributes.value.kdc_admin_password
      realm                                = kerberos_attributes.value.realm
    }
  }

  list_steps_states         = var.list_steps_states
  log_encryption_kms_key_id = var.log_encryption_kms_key_id
  log_uri                   = var.log_uri

  dynamic "master_instance_fleet" {
    for_each = var.master_instance_fleet != null ? [var.master_instance_fleet] : []

    content {
      dynamic "instance_type_configs" {
        for_each = master_instance_fleet.value.instance_type_configs != null ? master_instance_fleet.value.instance_type_configs : []

        content {
          bid_price                                  = instance_type_configs.value.bid_price
          bid_price_as_percentage_of_on_demand_price = instance_type_configs.value.bid_price_as_percentage_of_on_demand_price

          dynamic "configurations" {
            for_each = instance_type_configs.value.configurations != null ? instance_type_configs.value.configurations : []

            content {
              classification = configurations.value.classification
              properties     = configurations.value.properties
            }
          }

          dynamic "ebs_config" {
            for_each = instance_type_configs.value.ebs_config != null ? instance_type_configs.value.ebs_config : []

            content {
              iops                 = ebs_config.value.iops
              size                 = ebs_config.value.size
              type                 = ebs_config.value.type
              volumes_per_instance = ebs_config.value.volumes_per_instance
            }
          }

          instance_type     = instance_type_configs.value.instance_type
          weighted_capacity = instance_type_configs.value.weighted_capacity
        }
      }

      dynamic "launch_specifications" {
        for_each = master_instance_fleet.value.launch_specifications != null ? [master_instance_fleet.value.launch_specifications] : []

        content {
          dynamic "on_demand_specification" {
            for_each = launch_specifications.value.on_demand_specification != null ? [launch_specifications.value.on_demand_specification] : []

            content {
              allocation_strategy = on_demand_specification.value.allocation_strategy
            }
          }

          dynamic "spot_specification" {
            for_each = launch_specifications.value.spot_specification != null ? [launch_specifications.value.spot_specification] : []

            content {
              allocation_strategy      = spot_specification.value.allocation_strategy
              block_duration_minutes   = launch_specifications.value.spot_specification.block_duration_minutes
              timeout_action           = launch_specifications.value.spot_specification.timeout_action
              timeout_duration_minutes = launch_specifications.value.spot_specification.timeout_duration_minutes
            }
          }
        }
      }

      name                      = master_instance_fleet.value.name
      target_on_demand_capacity = master_instance_fleet.value.target_on_demand_capacity
      target_spot_capacity      = master_instance_fleet.value.target_spot_capacity
    }
  }

  dynamic "master_instance_group" {
    for_each = var.master_instance_group != null ? [var.master_instance_group] : []

    content {
      bid_price = master_instance_group.value.bid_price

      dynamic "ebs_config" {
        for_each = master_instance_group.value.ebs_config != null ? master_instance_group.value.ebs_config : []

        content {
          iops                 = ebs_config.value.iops
          size                 = ebs_config.value.size
          throughput           = ebs_config.value.throughput
          type                 = ebs_config.value.type
          volumes_per_instance = ebs_config.value.volumes_per_instance
        }
      }

      instance_count = master_instance_group.value.instance_count
      instance_type  = master_instance_group.value.instance_type
      name           = master_instance_group.value.name
    }
  }

  name             = var.name
  os_release_label = var.os_release_label

  dynamic "placement_group_config" {
    for_each = var.placement_group_config != null ? var.placement_group_config : []

    content {
      instance_role      = placement_group_config.value.instance_role
      placement_strategy = placement_group_config.value.placement_strategy
    }
  }

  release_label          = try(coalesce(var.release_label, element(data.aws_emr_release_labels.this[0].release_labels, 0)), "")
  scale_down_behavior    = var.scale_down_behavior
  security_configuration = var.create_security_configuration ? aws_emr_security_configuration.this[0].name : var.security_configuration_name
  service_role           = local.create_service_iam_role ? aws_iam_role.service[0].arn : var.service_iam_role_arn

  dynamic "step" {
    for_each = var.step != null ? var.step : []

    content {
      action_on_failure = step.value.action_on_failure

      dynamic "hadoop_jar_step" {
        for_each = step.value.hadoop_jar_step != null ? [step.value.hadoop_jar_step] : []

        content {
          args       = hadoop_jar_step.value.args
          jar        = hadoop_jar_step.value.jar
          main_class = hadoop_jar_step.value.main_class
          properties = hadoop_jar_step.value.properties
        }
      }

      name = step.value.name
    }
  }

  step_concurrency_level     = var.step_concurrency_level
  termination_protection     = var.termination_protection
  unhealthy_node_replacement = var.unhealthy_node_replacement
  visible_to_all_users       = var.visible_to_all_users

  tags = merge(
    local.tags,
    # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-role.html
    # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
    { "for-use-with-amazon-emr-managed-policies" = true },
  )

  depends_on = [
    aws_iam_role_policy_attachment.service,
    aws_iam_role_policy_attachment.service_pass_role,
    aws_iam_role_policy_attachment.instance_profile,
    aws_iam_role_policy_attachment.autoscaling,
    aws_security_group_rule.service
  ]

  lifecycle {
    ignore_changes = [
      kerberos_attributes, # Since the API does not return the actual values for Kerberos configurations
      step,                # Ignore outside changes to running cluster steps
    ]
  }
}

################################################################################
# Task Instance Fleet
# Ref: https://github.com/hashicorp/terraform-provider-aws/issues/29668
################################################################################

resource "aws_emr_instance_fleet" "this" {
  for_each = var.create && var.task_instance_fleet != null ? var.task_instance_fleet : object({})

  cluster_id = aws_emr_cluster.this[0].id

  dynamic "instance_type_configs" {
    for_each = each.value.instance_type_configs != null ? each.value.instance_type_configs : []

    content {
      bid_price                                  = instance_type_configs.value.bid_price
      bid_price_as_percentage_of_on_demand_price = instance_type_configs.value.bid_price_as_percentage_of_on_demand_price

      dynamic "configurations" {
        for_each = instance_type_configs.value.configurations != null ? instance_type_configs.value.configurations : []

        content {
          classification = configurations.value.classification
          properties     = configurations.value.properties
        }
      }

      dynamic "ebs_config" {
        for_each = instance_type_configs.value.ebs_config != null ? instance_type_configs.value.ebs_config : []

        content {
          iops                 = ebs_config.value.iops
          size                 = ebs_config.value.size
          type                 = ebs_config.value.type
          volumes_per_instance = ebs_config.value.volumes_per_instance
        }
      }

      instance_type     = instance_type_configs.value.instance_type
      weighted_capacity = instance_type_configs.value.weighted_capacity
    }
  }

  dynamic "launch_specifications" {
    for_each = each.value.launch_specifications != null ? [each.value.launch_specifications] : []

    content {
      dynamic "on_demand_specification" {
        for_each = launch_specifications.value.on_demand_specification != null ? [launch_specifications.value.on_demand_specification] : []

        content {
          allocation_strategy = on_demand_specification.value.allocation_strategy
        }
      }

      dynamic "spot_specification" {
        for_each = launch_specifications.value.spot_specification != null ? [launch_specifications.value.spot_specification] : []

        content {
          allocation_strategy      = spot_specification.value.allocation_strategy
          block_duration_minutes   = launch_specifications.value.spot_specification.block_duration_minutes
          timeout_action           = launch_specifications.value.spot_specification.timeout_action
          timeout_duration_minutes = launch_specifications.value.spot_specification.timeout_duration_minutes
        }
      }
    }
  }

  name                      = each.value.name
  target_on_demand_capacity = each.value.target_on_demand_capacity
  target_spot_capacity      = each.value.target_spot_capacity
}

################################################################################
# Task Instance Group
# Ref: https://github.com/hashicorp/terraform-provider-aws/issues/29668
################################################################################

resource "aws_emr_instance_group" "this" {
  for_each = var.create && var.task_instance_group != null ? var.task_instance_group : object({})

  autoscaling_policy  = each.value.autoscaling_policy
  bid_price           = each.value.bid_price
  cluster_id          = aws_emr_cluster.this[0].id
  configurations_json = each.value.configurations_json

  dynamic "ebs_config" {
    for_each = each.value.ebs_config != null ? each.value.ebs_config : []

    content {
      iops                 = ebs_config.value.iops
      size                 = ebs_config.value.size
      type                 = ebs_config.value.type
      volumes_per_instance = ebs_config.value.volumes_per_instance
    }
  }

  ebs_optimized  = each.value.ebs_optimized
  instance_count = each.value.instance_count
  instance_type  = each.value.instance_type
  name           = each.value.name
}

################################################################################
# Managed Scaling Policy
################################################################################

resource "aws_emr_managed_scaling_policy" "this" {
  count = var.create && var.managed_scaling_policy != null ? 1 : 0

  cluster_id = aws_emr_cluster.this[0].id

  compute_limits {
    maximum_capacity_units          = var.managed_scaling_policy.maximum_capacity_units
    maximum_core_capacity_units     = var.managed_scaling_policy.maximum_core_capacity_units
    maximum_ondemand_capacity_units = var.managed_scaling_policy.maximum_ondemand_capacity_units
    minimum_capacity_units          = var.managed_scaling_policy.minimum_capacity_units
    unit_type                       = var.managed_scaling_policy.unit_type
  }
}

################################################################################
# Security Configuration
################################################################################

locals {
  security_configuration_name = try(coalesce(var.security_configuration_name, var.name), "")
}

resource "aws_emr_security_configuration" "this" {
  count = var.create && var.create_security_configuration ? 1 : 0

  name          = var.security_configuration_use_name_prefix ? null : local.security_configuration_name
  name_prefix   = var.security_configuration_use_name_prefix ? "${local.security_configuration_name}-" : null
  configuration = var.security_configuration

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Autoscaling IAM Role
################################################################################

locals {
  # Autoscaling not supported when using instance fleets
  create_autoscaling_iam_role = var.create && var.create_autoscaling_iam_role && length(merge(var.core_instance_fleet, var.master_instance_fleet)) == 0
  autoscaling_iam_role_name   = coalesce(var.autoscaling_iam_role_name, "${var.name}-autoscaling")
}

resource "aws_iam_role" "autoscaling" {
  count = local.create_autoscaling_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.autoscaling_iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.autoscaling_iam_role_name}-" : null
  path        = var.iam_role_path
  description = coalesce(var.autoscaling_iam_role_description, "Autoscaling role for EMR cluster ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.autoscaling[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(local.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "autoscaling" {
  count = local.create_autoscaling_iam_role ? 1 : 0

  statement {
    sid     = "EMRAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "elasticmapreduce.${local.dns_suffix}",
        "application-autoscaling.${local.dns_suffix}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:elasticmapreduce:${local.region}:${local.account_id}:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "autoscaling" {
  count = local.create_autoscaling_iam_role ? 1 : 0

  role       = aws_iam_role.autoscaling[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

################################################################################
# Service IAM Role
################################################################################

locals {
  create_service_iam_role = var.create && var.create_service_iam_role
  service_iam_role_name   = coalesce(var.service_iam_role_name, "${var.name}-service")
}

resource "aws_iam_role" "service" {
  count = local.create_service_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.service_iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.service_iam_role_name}-" : null
  path        = var.iam_role_path
  description = coalesce(var.service_iam_role_description, "Service role for EMR cluster ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.service[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(
    local.tags,
    var.iam_role_tags,
    # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
    { "for-use-with-amazon-emr-managed-policies" = true },
  )
}

data "aws_iam_policy_document" "service" {
  count = local.create_service_iam_role ? 1 : 0

  statement {
    sid     = "EMRAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "elasticmapreduce.${local.dns_suffix}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:elasticmapreduce:${local.region}:${local.account_id}:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "service" {
  for_each = { for k, v in var.service_iam_role_policies : k => v if local.create_service_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.service[0].name
}

locals {
  service_pass_role_policy_name = coalesce(var.service_pass_role_policy_name, "${var.name}-passrole")
}

# https://repost.aws/questions/QUIa9mU4AqRdqikEcl0piZQg/emr-default-role-has-insufficient-ec-2-permissions
data "aws_iam_policy_document" "service_pass_role" {
  count = local.create_service_iam_role ? 1 : 0

  statement {
    sid     = "PassRoleForAutoScaling"
    actions = ["iam:PassRole"]

    resources = compact([
      try(aws_iam_role.autoscaling[0].arn, ""),
      try(aws_iam_role.instance_profile[0].arn, ""),
      var.autoscaling_iam_role_arn,
      var.iam_instance_profile_role_arn
    ])

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "application-autoscaling.${local.dns_suffix}",
        "ec2.${local.dns_suffix}",
      ]
    }
  }
}

resource "aws_iam_policy" "service_pass_role" {
  count = local.create_service_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.service_pass_role_policy_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.service_pass_role_policy_name}-" : null
  path        = var.iam_role_path
  description = coalesce(var.service_pass_role_policy_description, "Service role permissions to pass autoscaling and instance profile roles")

  policy = data.aws_iam_policy_document.service_pass_role[0].json
}

resource "aws_iam_role_policy_attachment" "service_pass_role" {
  count = local.create_service_iam_role ? 1 : 0

  policy_arn = aws_iam_policy.service_pass_role[0].arn
  role       = aws_iam_role.service[0].name
}

################################################################################
# Instance Profile
################################################################################

locals {
  create_iam_instance_profile = var.create && var.create_iam_instance_profile
  iam_instance_profile_name   = coalesce(var.iam_instance_profile_name, "${var.name}-instance")
}

data "aws_iam_policy_document" "instance_profile" {
  count = local.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${local.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "instance_profile" {
  count = local.create_iam_instance_profile ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_instance_profile_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_instance_profile_name}-" : null
  path        = var.iam_role_path
  description = var.iam_instance_profile_description

  assume_role_policy    = data.aws_iam_policy_document.instance_profile[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(local.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "instance_profile" {
  for_each = { for k, v in var.iam_instance_profile_policies : k => v if local.create_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.instance_profile[0].name
}

resource "aws_iam_instance_profile" "this" {
  count = local.create_iam_instance_profile ? 1 : 0

  role = aws_iam_role.instance_profile[0].name

  name        = var.iam_role_use_name_prefix ? null : local.iam_instance_profile_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_instance_profile_name}-" : null
  path        = var.iam_role_path

  tags = merge(local.tags, var.iam_role_tags)

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Managed Master Security Group
################################################################################

locals {
  create_managed_security_groups = var.create && var.create_managed_security_groups
  managed_security_group_name    = try(coalesce(var.managed_security_group_name, var.name), "")

  master_security_group_name = "${local.managed_security_group_name}-master"
}

resource "aws_security_group" "master" {
  count = local.create_managed_security_groups ? 1 : 0

  name                   = var.managed_security_group_use_name_prefix ? null : local.master_security_group_name
  name_prefix            = var.managed_security_group_use_name_prefix ? "${local.master_security_group_name}-" : null
  description            = var.master_security_group_description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    local.tags,
    var.managed_security_group_tags,
    {
      "Name" = local.master_security_group_name
      # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
      "for-use-with-amazon-emr-managed-policies" = true
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master" {
  for_each = { for k, v in var.master_security_group_rules : k => v if local.create_managed_security_groups }

  description              = each.value.description
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  security_group_id        = aws_security_group.master[0].id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_slave_security_group ? aws_security_group.slave[0].id : lookup(each.value, "source_security_group_id", null)
}

################################################################################
# Managed Slave Security Group
################################################################################

locals {
  slave_security_group_name = "${local.managed_security_group_name}-slave"
}

resource "aws_security_group" "slave" {
  count = local.create_managed_security_groups ? 1 : 0

  name                   = var.managed_security_group_use_name_prefix ? null : local.slave_security_group_name
  name_prefix            = var.managed_security_group_use_name_prefix ? "${local.slave_security_group_name}-" : null
  description            = var.slave_security_group_description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    local.tags,
    var.managed_security_group_tags,
    {
      "Name" = local.slave_security_group_name
      # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
      "for-use-with-amazon-emr-managed-policies" = true
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "slave" {
  for_each = { for k, v in var.slave_security_group_rules : k => v if local.create_managed_security_groups }

  description              = each.value.description
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  security_group_id        = aws_security_group.master[0].id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_master_security_group ? aws_security_group.master[0].id : lookup(each.value, "source_security_group_id", null)
}

################################################################################
# Managed Service Access Security Group
################################################################################

locals {
  create_service_security_group = local.create_managed_security_groups && var.is_private_cluster
  service_security_group_name   = "${local.managed_security_group_name}-service"

  service_security_group_rules = merge(
    {
      "master_9443_ingress" = {
        description              = "Master security group secure communication"
        type                     = "ingress"
        protocol                 = "tcp"
        from_port                = 9443
        to_port                  = 9443
        source_security_group_id = try(aws_security_group.master[0].id, "")
      }
      "core_task_8443_egress" = {
        description              = "Allow the cluster manager to communicate with the core and task nodes"
        type                     = "egress"
        protocol                 = "tcp"
        from_port                = 8443
        to_port                  = 8443
        source_security_group_id = try(aws_security_group.slave[0].id, "")
      }
      "master_9443_egress" = {
        description              = "Allow the cluster manager to communicate with the master nodes"
        type                     = "egress"
        protocol                 = "tcp"
        from_port                = 8443
        to_port                  = 8443
        source_security_group_id = try(aws_security_group.master[0].id, "")
      }
    },
    var.service_security_group_rules
  )
}

resource "aws_security_group" "service" {
  count = local.create_service_security_group ? 1 : 0

  name                   = var.managed_security_group_use_name_prefix ? null : local.service_security_group_name
  name_prefix            = var.managed_security_group_use_name_prefix ? "${local.service_security_group_name}-" : null
  description            = var.service_security_group_description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    local.tags,
    var.managed_security_group_tags,
    {
      "Name" = local.service_security_group_name
      # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
      "for-use-with-amazon-emr-managed-policies" = true
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "service" {
  for_each = { for k, v in local.service_security_group_rules : k => v if local.create_service_security_group }

  description              = each.value.description
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  security_group_id        = aws_security_group.master[0].id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_master_security_group ? aws_security_group.master[0].id : lookup(each.value, "source_security_group_id", null)
}

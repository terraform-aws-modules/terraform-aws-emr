data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_emr_release_labels" "this" {
  count = var.create && length(var.release_label_filters) > 0 ? 1 : 0

  dynamic "filters" {
    for_each = var.release_label_filters

    content {
      application = try(filters.value.application, null)
      prefix      = try(filters.value.prefix, null)
    }
  }
}

locals {
  tags = merge(var.tags, { terraform-aws-modules = "emr" })
}

################################################################################
# Cluster
################################################################################

resource "aws_emr_cluster" "this" {
  count = var.create ? 1 : 0

  additional_info = var.additional_info
  applications    = var.applications

  dynamic "auto_termination_policy" {
    for_each = length(var.auto_termination_policy) > 0 ? [var.auto_termination_policy] : []

    content {
      idle_timeout = try(auto_termination_policy.value.idle_timeout, null)
    }
  }

  autoscaling_role = local.create_autoscaling_iam_role ? aws_iam_role.autoscaling[0].arn : var.autoscaling_iam_role_arn

  dynamic "bootstrap_action" {
    for_each = var.bootstrap_action

    content {
      args = try(bootstrap_action.value.args, null)
      name = bootstrap_action.value.name
      path = bootstrap_action.value.path
    }
  }

  configurations      = var.configurations
  configurations_json = var.configurations_json

  dynamic "core_instance_fleet" {
    for_each = length(var.core_instance_fleet) > 0 ? [var.core_instance_fleet] : []

    content {
      dynamic "instance_type_configs" {
        for_each = try(core_instance_fleet.value.instance_type_configs, [])

        content {
          bid_price                                  = try(instance_type_configs.value.bid_price, null)
          bid_price_as_percentage_of_on_demand_price = try(instance_type_configs.value.bid_price_as_percentage_of_on_demand_price, 60)

          dynamic "configurations" {
            for_each = try(instance_type_configs.value.configurations, [])

            content {
              classification = try(configurations.value.classification, null)
              properties     = try(configurations.value.properties, null)
            }
          }

          dynamic "ebs_config" {
            for_each = try(instance_type_configs.value.ebs_config, [])

            content {
              iops                 = try(ebs_config.value.iops, null)
              size                 = try(ebs_config.value.size, 64)
              type                 = try(ebs_config.value.type, "gp3")
              volumes_per_instance = try(ebs_config.value.volumes_per_instance, null)
            }
          }

          instance_type     = instance_type_configs.value.instance_type
          weighted_capacity = try(instance_type_configs.value.weighted_capacity, null)
        }
      }

      dynamic "launch_specifications" {
        for_each = try([core_instance_fleet.value.launch_specifications], [])

        content {
          dynamic "on_demand_specification" {
            for_each = try([launch_specifications.value.on_demand_specification], [])

            content {
              allocation_strategy = try(on_demand_specification.value.allocation_strategy, "lowest-price")
            }
          }

          dynamic "spot_specification" {
            for_each = try([launch_specifications.value.spot_specification], [])

            content {
              allocation_strategy      = try(spot_specification.value.allocation_strategy, "capacity-optimized")
              block_duration_minutes   = try(launch_specifications.value.spot_specification.block_duration_minutes, null)
              timeout_action           = try(launch_specifications.value.spot_specification.timeout_action, "SWITCH_TO_ON_DEMAND")
              timeout_duration_minutes = try(launch_specifications.value.spot_specification.timeout_duration_minutes, 60)
            }
          }
        }
      }

      name                      = try(core_instance_fleet.value.name, null)
      target_on_demand_capacity = try(core_instance_fleet.value.target_on_demand_capacity, null)
      target_spot_capacity      = try(core_instance_fleet.value.target_spot_capacity, null)
    }
  }

  dynamic "core_instance_group" {
    for_each = length(var.core_instance_group) > 0 ? [var.core_instance_group] : []

    content {
      autoscaling_policy = try(core_instance_group.value.autoscaling_policy, null)
      bid_price          = try(core_instance_group.value.bid_price, null)

      dynamic "ebs_config" {
        for_each = try(core_instance_group.value.ebs_config, [])

        content {
          iops                 = try(ebs_config.value.iops, null)
          size                 = try(ebs_config.value.size, 64)
          throughput           = try(ebs_config.value.throughput, null)
          type                 = try(ebs_config.value.type, "gp3")
          volumes_per_instance = try(ebs_config.value.volumes_per_instance, null)
        }
      }

      instance_count = try(core_instance_group.value.instance_count, null)
      instance_type  = core_instance_group.value.instance_type
      name           = try(core_instance_group.value.name, null)
    }
  }

  custom_ami_id        = var.custom_ami_id
  ebs_root_volume_size = var.ebs_root_volume_size

  dynamic "ec2_attributes" {
    for_each = length(var.ec2_attributes) > 0 || local.create_managed_security_groups || local.create_iam_instance_profile ? [var.ec2_attributes] : []

    content {
      additional_master_security_groups = try(ec2_attributes.value.additional_master_security_groups, null)
      additional_slave_security_groups  = try(ec2_attributes.value.additional_slave_security_groups, null)
      emr_managed_master_security_group = local.create_managed_security_groups ? aws_security_group.master[0].id : try(ec2_attributes.value.emr_managed_master_security_group, null)
      emr_managed_slave_security_group  = local.create_managed_security_groups ? aws_security_group.slave[0].id : try(ec2_attributes.value.emr_managed_slave_security_group, null)
      instance_profile                  = local.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : ec2_attributes.value.instance_profile
      key_name                          = try(ec2_attributes.value.key_name, null)
      service_access_security_group     = local.create_service_security_group ? aws_security_group.service[0].id : try(ec2_attributes.value.service_access_security_group, null)
      subnet_id                         = try(ec2_attributes.value.subnet_id, null)
      subnet_ids                        = try(ec2_attributes.value.subnet_ids, null)
    }
  }

  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps

  dynamic "kerberos_attributes" {
    for_each = length(var.kerberos_attributes) > 0 ? [var.kerberos_attributes] : []

    content {
      ad_domain_join_password              = try(kerberos_attributes.value.ad_domain_join_password, null)
      ad_domain_join_user                  = try(kerberos_attributes.value.ad_domain_join_user, null)
      cross_realm_trust_principal_password = try(kerberos_attributes.value.cross_realm_trust_principal_password, null)
      kdc_admin_password                   = kerberos_attributes.value.kdc_admin_password
      realm                                = kerberos_attributes.value.realm
    }
  }

  list_steps_states         = var.list_steps_states
  log_encryption_kms_key_id = var.log_encryption_kms_key_id
  log_uri                   = var.log_uri

  dynamic "master_instance_fleet" {
    for_each = length(var.master_instance_fleet) > 0 ? [var.master_instance_fleet] : []

    content {
      dynamic "instance_type_configs" {
        for_each = try(master_instance_fleet.value.instance_type_configs, [])

        content {
          bid_price                                  = try(instance_type_configs.value.bid_price, null)
          bid_price_as_percentage_of_on_demand_price = try(instance_type_configs.value.bid_price_as_percentage_of_on_demand_price, null)

          dynamic "configurations" {
            for_each = try(instance_type_configs.value.configurations, [])

            content {
              classification = try(configurations.value.classification, null)
              properties     = try(configurations.value.properties, null)
            }
          }

          dynamic "ebs_config" {
            for_each = try(instance_type_configs.value.ebs_config, [])

            content {
              iops                 = try(ebs_config.value.iops, null)
              size                 = try(ebs_config.value.size, 64)
              type                 = try(ebs_config.value.type, "gp3")
              volumes_per_instance = try(ebs_config.value.volumes_per_instance, null)
            }
          }

          instance_type     = instance_type_configs.value.instance_type
          weighted_capacity = try(instance_type_configs.value.weighted_capacity, null)
        }
      }

      dynamic "launch_specifications" {
        for_each = try([master_instance_fleet.value.launch_specifications], [])

        content {
          dynamic "on_demand_specification" {
            for_each = try([launch_specifications.value.on_demand_specification], [])

            content {
              allocation_strategy = try(on_demand_specification.value.allocation_strategy, "lowest-price")
            }
          }

          dynamic "spot_specification" {
            for_each = try([launch_specifications.value.spot_specification], [])

            content {
              allocation_strategy      = try(spot_specification.value.allocation_strategy, "capacity-optimized")
              block_duration_minutes   = try(launch_specifications.value.spot_specification.block_duration_minutes, null)
              timeout_action           = try(launch_specifications.value.spot_specification.timeout_action, "SWITCH_TO_ON_DEMAND")
              timeout_duration_minutes = try(launch_specifications.value.spot_specification.timeout_duration_minutes, 60)
            }
          }
        }
      }

      name                      = try(master_instance_fleet.value.name, null)
      target_on_demand_capacity = try(master_instance_fleet.value.target_on_demand_capacity, null)
      target_spot_capacity      = try(master_instance_fleet.value.target_spot_capacity, null)
    }
  }

  dynamic "master_instance_group" {
    for_each = length(var.master_instance_group) > 0 ? [var.master_instance_group] : []

    content {
      bid_price = try(master_instance_group.value.bid_price, null)

      dynamic "ebs_config" {
        for_each = try(master_instance_group.value.ebs_config, [])

        content {
          iops                 = try(ebs_config.value.iops, null)
          size                 = try(ebs_config.value.size, 64)
          throughput           = try(ebs_config.value.throughput, null)
          type                 = try(ebs_config.value.type, "gp3")
          volumes_per_instance = try(ebs_config.value.volumes_per_instance, null)
        }
      }

      instance_count = try(master_instance_group.value.instance_count, null)
      instance_type  = master_instance_group.value.instance_type
      name           = try(master_instance_group.value.name, null)
    }
  }

  dynamic "placement_group_config" {
    for_each = var.placement_group_config

    content {
      instance_role      = placement_group_config.value.instance_role
      placement_strategy = try(placement_group_config.value.placement_strategy, null)
    }
  }

  name                   = var.name
  release_label          = try(coalesce(var.release_label, element(data.aws_emr_release_labels.this[0].release_labels, 0)), "")
  scale_down_behavior    = var.scale_down_behavior
  security_configuration = var.create_security_configuration ? aws_emr_security_configuration.this[0].name : var.security_configuration_name
  service_role           = local.create_service_iam_role ? aws_iam_role.service[0].arn : var.service_iam_role_arn

  dynamic "step" {
    for_each = var.step

    content {
      action_on_failure = step.value.action_on_failure

      dynamic "hadoop_jar_step" {
        for_each = try([step.value.hadoop_jar_step], [])

        content {
          args       = try(hadoop_jar_step.value.args, null)
          jar        = hadoop_jar_step.value.jar
          main_class = try(hadoop_jar_step.value.main_class, null)
          properties = try(hadoop_jar_step.value.properties, null)
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
  for_each = { for k, v in [var.task_instance_fleet] : k => v if var.create && length(var.task_instance_fleet) > 0 }

  cluster_id = aws_emr_cluster.this[0].id

  dynamic "instance_type_configs" {
    for_each = try(each.value.instance_type_configs, [])

    content {
      bid_price                                  = try(instance_type_configs.value.bid_price, null)
      bid_price_as_percentage_of_on_demand_price = try(instance_type_configs.value.bid_price_as_percentage_of_on_demand_price, 60)

      dynamic "configurations" {
        for_each = try(instance_type_configs.value.configurations, [])

        content {
          classification = try(configurations.value.classification, null)
          properties     = try(configurations.value.properties, null)
        }
      }

      dynamic "ebs_config" {
        for_each = try(instance_type_configs.value.ebs_config, [])

        content {
          iops                 = try(ebs_config.value.iops, null)
          size                 = try(ebs_config.value.size, 64)
          type                 = try(ebs_config.value.type, "gp3")
          volumes_per_instance = try(ebs_config.value.volumes_per_instance, null)
        }
      }

      instance_type     = instance_type_configs.value.instance_type
      weighted_capacity = try(instance_type_configs.value.weighted_capacity, null)
    }
  }

  dynamic "launch_specifications" {
    for_each = try([each.value.launch_specifications], [])

    content {
      dynamic "on_demand_specification" {
        for_each = try([launch_specifications.value.on_demand_specification], [])

        content {
          allocation_strategy = try(on_demand_specification.value.allocation_strategy, "lowest-price")
        }
      }

      dynamic "spot_specification" {
        for_each = try([launch_specifications.value.spot_specification], [])

        content {
          allocation_strategy      = try(spot_specification.value.allocation_strategy, "capacity-optimized")
          block_duration_minutes   = try(launch_specifications.value.spot_specification.block_duration_minutes, null)
          timeout_action           = try(launch_specifications.value.spot_specification.timeout_action, "SWITCH_TO_ON_DEMAND")
          timeout_duration_minutes = try(launch_specifications.value.spot_specification.timeout_duration_minutes, 60)
        }
      }
    }
  }

  name                      = try(each.value.name, null)
  target_on_demand_capacity = try(each.value.target_on_demand_capacity, null)
  target_spot_capacity      = try(each.value.target_spot_capacity, null)
}

################################################################################
# Task Instance Group
# Ref: https://github.com/hashicorp/terraform-provider-aws/issues/29668
################################################################################

resource "aws_emr_instance_group" "this" {
  for_each = { for k, v in [var.task_instance_group] : k => v if var.create && length(var.task_instance_group) > 0 }

  autoscaling_policy  = try(each.value.autoscaling_policy, null)
  bid_price           = try(each.value.bid_price, null)
  cluster_id          = aws_emr_cluster.this[0].id
  configurations_json = try(each.value.configurations_json, null)

  dynamic "ebs_config" {
    for_each = try(each.value.ebs_config, [])

    content {
      iops = try(ebs_config.value.iops, null)
      size = try(ebs_config.value.size, 64)
      # throughput           = try(ebs_config.value.throughput, null)
      type                 = try(ebs_config.value.type, "gp3")
      volumes_per_instance = try(ebs_config.value.volumes_per_instance, null)
    }
  }

  ebs_optimized  = try(each.value.ebs_optimized, true)
  instance_count = try(each.value.instance_count, null)
  instance_type  = each.value.instance_type
  name           = try(each.value.name, null)
}

################################################################################
# Managed Scaling Policy
################################################################################

resource "aws_emr_managed_scaling_policy" "this" {
  count = var.create && length(var.managed_scaling_policy) > 0 ? 1 : 0

  cluster_id = aws_emr_cluster.this[0].id

  compute_limits {
    unit_type                       = var.managed_scaling_policy.unit_type
    minimum_capacity_units          = var.managed_scaling_policy.minimum_capacity_units
    maximum_capacity_units          = var.managed_scaling_policy.maximum_capacity_units
    maximum_core_capacity_units     = try(var.managed_scaling_policy.maximum_core_capacity_units, null)
    maximum_ondemand_capacity_units = try(var.managed_scaling_policy.maximum_ondemand_capacity_units, null)
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
        "elasticmapreduce.${data.aws_partition.current.dns_suffix}",
        "application-autoscaling.${data.aws_partition.current.dns_suffix}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:elasticmapreduce:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "autoscaling" {
  count = local.create_autoscaling_iam_role ? 1 : 0

  role       = aws_iam_role.autoscaling[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
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
        "elasticmapreduce.${data.aws_partition.current.dns_suffix}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:elasticmapreduce:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
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
    ])

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "application-autoscaling.${data.aws_partition.current.dns_suffix}",
        "ec2.${data.aws_partition.current.dns_suffix}",
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
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
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

  # Required
  security_group_id = aws_security_group.master[0].id
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
  source_security_group_id = try(each.value.source_slave_security_group, false) ? aws_security_group.master[0].id : lookup(each.value, "source_security_group_id", null)
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

  # Required
  security_group_id = aws_security_group.slave[0].id
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
  source_security_group_id = try(each.value.source_master_security_group, false) ? aws_security_group.master[0].id : lookup(each.value, "source_security_group_id", null)
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

  # Required
  security_group_id = aws_security_group.service[0].id
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
  source_security_group_id = try(each.value.source_master_security_group, false) ? aws_security_group.master[0].id : lookup(each.value, "source_security_group_id", null)
}

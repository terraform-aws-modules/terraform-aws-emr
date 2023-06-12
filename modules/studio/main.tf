data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  auth_mode_is_sso = var.auth_mode == "SSO"

  tags = merge(var.tags, { terraform-aws-modules = "emr" })
}

################################################################################
# Studio
################################################################################

resource "aws_emr_studio" "this" {
  count = var.create ? 1 : 0

  auth_mode                      = var.auth_mode
  default_s3_location            = var.default_s3_location
  description                    = var.description
  engine_security_group_id       = local.create_security_groups ? aws_security_group.engine[0].id : var.engine_security_group_id
  idp_auth_url                   = var.idp_auth_url
  idp_relay_state_parameter_name = var.idp_relay_state_parameter_name
  name                           = var.name
  service_role                   = var.create_service_role ? aws_iam_role.service[0].arn : var.service_role_arn
  subnet_ids                     = var.subnet_ids
  user_role                      = var.create_user_role && local.auth_mode_is_sso ? aws_iam_role.user[0].arn : var.user_role_arn
  vpc_id                         = var.vpc_id
  workspace_security_group_id    = local.create_security_groups ? aws_security_group.workspace[0].id : var.workspace_security_group_id

  tags = local.tags
}

################################################################################
# Service IAM Role
################################################################################

locals {
  create_service_role        = var.create && var.create_service_role
  create_service_role_policy = local.create_service_role && var.create_service_role_policy

  service_role_name = coalesce(var.service_role_name, "${var.name}-service")
}

resource "aws_iam_role" "service" {
  count = local.create_service_role ? 1 : 0

  name        = var.service_role_use_name_prefix ? null : local.service_role_name
  name_prefix = var.service_role_use_name_prefix ? "${local.service_role_name}-" : null
  path        = var.service_role_path
  description = coalesce(var.service_role_description, "Service role for EMR Studio ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.service_assume[0].json
  permissions_boundary  = var.service_role_permissions_boundary
  force_detach_policies = true

  tags = merge(local.tags, var.service_role_tags)
}

data "aws_iam_policy_document" "service_assume" {
  count = local.create_service_role ? 1 : 0

  statement {
    sid     = "EMRAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.${data.aws_partition.current.dns_suffix}"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:elasticmapreduce:${local.region}:${local.account_id}:*"]
    }
  }
}

################################################################################
# Service IAM Role Policy
################################################################################

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-studio-service-role.html#emr-studio-service-role-permissions-table
data "aws_iam_policy_document" "service" {
  count = local.create_service_role_policy ? 1 : 0

  statement {
    sid = "AllowEMRReadOnlyActions"
    actions = [
      "elasticmapreduce:ListInstances",
      "elasticmapreduce:DescribeCluster",
      "elasticmapreduce:ListSteps",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowEC2ENIActionsWithEMRTags"
    actions = [
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid     = "AllowEC2ENIAttributeAction"
    actions = ["ec2:ModifyNetworkInterfaceAttribute"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:network-interface/*",
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:security-group/*",
    ]
  }

  statement {
    sid = "AllowEC2SecurityGroupActionsWithEMRTags"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteNetworkInterfacePermission",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowDefaultEC2SecurityGroupsCreationWithEMRTags"
    actions   = ["ec2:CreateSecurityGroup"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowDefaultEC2SecurityGroupsCreationInVPCWithEMRTags"
    actions   = ["ec2:CreateSecurityGroup"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:vpc/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowAddingEMRTagsDuringDefaultSecurityGroupCreation"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
  }

  statement {
    sid       = "AllowEC2ENICreationWithEMRTags"
    actions   = ["ec2:CreateNetworkInterface"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid     = "AllowEC2ENICreationInSubnetAndSecurityGroupWithEMRTags"
    actions = ["ec2:CreateNetworkInterface"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:subnet/*",
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:security-group/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowAddingTagsDuringEC2ENICreation"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateNetworkInterface"]
    }
  }

  statement {
    sid = "AllowEC2ReadOnlyActions"
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.service_role_secrets_manager_arns) == 0 ? [1] : []

    content {
      sid       = "AllowSecretsManagerReadOnlyActionsWithEMRTags"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["arn:${local.partition}:secretsmanager:${local.region}:${local.account_id}:secret:*"]

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceTag/for-use-with-amazon-emr-managed-policies"
        values   = ["true"]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.service_role_secrets_manager_arns) > 0 ? [1] : []

    content {
      sid       = "AllowSecretsManagerReadOnlyActionsWithARNs"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.service_role_secrets_manager_arns
    }
  }

  statement {
    sid = "AllowWorkspaceCollaboration"
    actions = [
      "iam:GetUser",
      "iam:GetRole",
      "iam:ListUsers",
      "iam:ListRoles",
      "sso:GetManagedApplicationInstance",
      "sso-directory:SearchUsers",
    ]
    resources = ["*"]
  }

  statement {
    sid = "S3ReadWrite"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetEncryptionConfiguration",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    resources = coalescelist(
      var.service_role_s3_bucket_arns,
      ["arn:${local.partition}:s3:::*"]
    )
  }

  dynamic "statement" {
    for_each = var.service_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "service" {
  count = local.create_service_role_policy ? 1 : 0

  name        = var.service_role_use_name_prefix ? null : local.service_role_name
  name_prefix = var.service_role_use_name_prefix ? "${local.service_role_name}-" : null
  path        = var.service_role_path
  description = coalesce(var.service_role_description, "Service role policy for EMR Studio ${var.name}")

  policy = data.aws_iam_policy_document.service[0].json

  tags = merge(local.tags, var.service_role_tags)
}

resource "aws_iam_role_policy_attachment" "service" {
  count = local.create_service_role_policy ? 1 : 0

  policy_arn = aws_iam_policy.service[0].arn
  role       = aws_iam_role.service[0].name
}

resource "aws_iam_role_policy_attachment" "service_additional" {
  for_each = { for k, v in var.service_role_policies : k => v if local.create_service_role }

  policy_arn = each.value
  role       = aws_iam_role.service[0].name
}

################################################################################
# Studio Session Mapping
################################################################################

resource "aws_emr_studio_session_mapping" "this" {
  for_each = { for k, v in var.session_mappings : k => v if var.create && local.auth_mode_is_sso }

  identity_id        = try(each.value.identity_id, null)
  identity_name      = try(each.value.identity_name, null)
  identity_type      = each.value.identity_type
  session_policy_arn = try(each.value.session_policy_arn, aws_iam_policy.user[0].arn)
  studio_id          = aws_emr_studio.this[0].id
}

################################################################################
# User IAM Role
################################################################################

locals {
  create_user_role = var.create && var.create_user_role && local.auth_mode_is_sso

  user_role_name = coalesce(var.user_role_name, "${var.name}-user")
}

resource "aws_iam_role" "user" {
  count = local.create_user_role ? 1 : 0

  name        = var.user_role_use_name_prefix ? null : local.user_role_name
  name_prefix = var.user_role_use_name_prefix ? "${local.user_role_name}-" : null
  path        = var.user_role_path
  description = var.user_role_description

  assume_role_policy    = data.aws_iam_policy_document.user_assume[0].json
  permissions_boundary  = var.user_role_permissions_boundary
  force_detach_policies = true

  tags = merge(local.tags, var.user_role_tags)
}

data "aws_iam_policy_document" "user_assume" {
  count = local.create_user_role ? 1 : 0

  statement {
    sid     = "EMRAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "user_additional" {
  for_each = { for k, v in var.user_role_policies : k => v if local.create_user_role }

  policy_arn = each.value
  role       = aws_iam_role.user[0].name
}

################################################################################
# User IAM Role Policy
################################################################################

locals {
  create_user_role_policy = var.create && var.create_user_role_policy && local.auth_mode_is_sso
}

data "aws_iam_policy_document" "user" {
  count = local.create_user_role_policy ? 1 : 0

  statement {
    sid = "AllowEMRBasicActions"
    actions = [
      "elasticmapreduce:CreateEditor",
      "elasticmapreduce:DescribeEditor",
      "elasticmapreduce:ListEditors",
      "elasticmapreduce:StartEditor",
      "elasticmapreduce:StopEditor",
      "elasticmapreduce:DeleteEditor",
      "elasticmapreduce:OpenEditorInConsole",
      "elasticmapreduce:AttachEditor",
      "elasticmapreduce:DetachEditor",
      "elasticmapreduce:CreateRepository",
      "elasticmapreduce:DescribeRepository",
      "elasticmapreduce:DeleteRepository",
      "elasticmapreduce:ListRepositories",
      "elasticmapreduce:LinkRepository",
      "elasticmapreduce:UnlinkRepository",
      "elasticmapreduce:DescribeCluster",
      "elasticmapreduce:ListInstanceGroups",
      "elasticmapreduce:ListBootstrapActions",
      "elasticmapreduce:ListClusters",
      "elasticmapreduce:ListSteps",
      "elasticmapreduce:CreatePersistentAppUI",
      "elasticmapreduce:DescribePersistentAppUI",
      "elasticmapreduce:GetPersistentAppUIPresignedURL",
      "elasticmapreduce:GetOnClusterAppUIPresignedURL",
      # Additional
      "emr-serverless:*",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowEMRContainersBasicActions"
    actions = [
      "emr-containers:DescribeVirtualCluster",
      "emr-containers:ListVirtualClusters",
      "emr-containers:DescribeManagedEndpoint",
      "emr-containers:ListManagedEndpoints",
      "emr-containers:DescribeJobRun",
      "emr-containers:ListJobRuns"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowSecretManagerListSecrets"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowSecretCreationWithEMRTagsAndEMRStudioPrefix"
    actions   = ["secretsmanager:CreateSecret"]
    resources = ["arn:${local.partition}:secretsmanager:${local.region}:${local.account_id}:secret:emr-studio-*", ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/for-use-with-amazon-emr-managed-policies"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowAddingTagsOnSecretsWithEMRStudioPrefix"
    actions   = ["secretsmanager:TagResource"]
    resources = ["arn:${local.partition}:secretsmanager:${local.region}:${local.account_id}:secret:emr-studio-*"]
  }

  statement {
    sid = "AllowClusterTemplateRelatedIntermediateActions"
    actions = [
      "servicecatalog:DescribeProduct",
      "servicecatalog:DescribeProductView",
      "servicecatalog:DescribeProvisioningParameters",
      "servicecatalog:ProvisionProduct",
      "servicecatalog:SearchProducts",
      "servicecatalog:UpdateProvisionedProduct",
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:ListLaunchPaths",
      "servicecatalog:DescribeRecord",
      "cloudformation:DescribeStackResources",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowEMRCreateClusterAdvancedActions"
    actions   = ["elasticmapreduce:RunJobFlow"]
    resources = ["*"]
  }

  statement {
    sid     = "AllowPassingServiceRoleForWorkspaceCreation"
    actions = ["iam:PassRole"]
    resources = [
      var.create_service_role ? aws_iam_role.service[0].arn : var.service_role_arn,
      "arn:${local.partition}:iam::${local.account_id}:role/EMR_DefaultRole_V2",
      "arn:${local.partition}:iam::${local.account_id}:role/EMR_EC2_DefaultRole",
    ]
  }

  statement {
    sid = "AllowS3ListAndLocationPermissions"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = coalescelist(
      var.user_role_s3_bucket_arns,
      ["arn:${local.partition}:s3:::*"],
    )
  }

  statement {
    sid       = "AllowS3ReadOnlyAccessToLogs"
    actions   = ["s3:GetObject"]
    resources = ["arn:${local.partition}:s3:::aws-logs-${local.account_id}-${local.region}/elasticmapreduce/*"]
  }

  statement {
    sid = "AllowConfigurationForWorkspaceCollaboration"
    actions = [
      "elasticmapreduce:UpdateEditor",
      "elasticmapreduce:PutWorkspaceAccess",
      "elasticmapreduce:DeleteWorkspaceAccess",
      "elasticmapreduce:ListWorkspaceAccessIdentities",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "elasticmapreduce:ResourceTag/creatorUserId"
      values   = ["$${aws:userId}"]
    }
  }

  statement {
    sid = "DescribeNetwork"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ListIAMRoles"
    actions   = ["iam:ListRoles"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.user_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "user" {
  count = local.create_user_role_policy ? 1 : 0

  name        = var.user_role_use_name_prefix ? null : local.user_role_name
  name_prefix = var.user_role_use_name_prefix ? "${local.user_role_name}-" : null
  path        = var.user_role_path
  description = coalesce(var.user_role_description, "User role policy for EMR Studio ${var.name}")

  policy = data.aws_iam_policy_document.user[0].json

  tags = merge(local.tags, var.user_role_tags)
}

resource "aws_iam_role_policy_attachment" "user" {
  count = local.create_user_role && local.create_user_role_policy ? 1 : 0

  policy_arn = aws_iam_policy.user[0].arn
  role       = aws_iam_role.user[0].name
}

################################################################################
# Engine Security Group
################################################################################

locals {
  create_security_groups = var.create && var.create_security_groups
  security_group_name    = try(coalesce(var.security_group_name, var.name), "")

  engine_security_group_name = "${local.security_group_name}-engine"
  engine_security_group_rules = { for k, v in merge(
    var.engine_security_group_rules,
    {
      workspace_ingress = {
        protocol                 = "tcp"
        from_port                = 18888
        to_port                  = 18888
        type                     = "ingress"
        description              = "Allow traffic from any resources in the Workspace security group for EMR Studio"
        source_security_group_id = try(aws_security_group.workspace[0].id, null)
      }
    },

  ) : k => v if local.create_security_groups }
}

resource "aws_security_group" "engine" {
  count = local.create_security_groups ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.engine_security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.engine_security_group_name}-" : null
  description = var.engine_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.security_group_tags,
    { "Name" = local.engine_security_group_name },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "engine" {
  for_each = { for k, v in local.engine_security_group_rules : k => v if local.create_security_groups }

  # Required
  security_group_id = aws_security_group.engine[0].id
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

################################################################################
# Workspace Security Group
################################################################################

locals {
  workspace_security_group_name = "${local.security_group_name}-workspace"
  workspace_security_group_rules = { for k, v in merge(
    var.workspace_security_group_rules,
    {
      engine_egress = {
        protocol                 = "tcp"
        from_port                = 18888
        to_port                  = 18888
        description              = "Allow traffic to any resources in the Engine security group for EMR Studio"
        source_security_group_id = try(aws_security_group.engine[0].id, null)
      }
      https_egress = {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        description = "Allow traffic to the internet to link publicly hosted Git repositories to Workspaces"
        cidr_blocks = ["0.0.0.0/0"]
      }
    },

  ) : k => v if local.create_security_groups }
}

resource "aws_security_group" "workspace" {
  count = local.create_security_groups ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.workspace_security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.workspace_security_group_name}-" : null
  description = var.workspace_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.security_group_tags,
    { "Name" = local.workspace_security_group_name },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "workspace" {
  for_each = { for k, v in local.workspace_security_group_rules : k => v if local.create_security_groups }

  # Required
  security_group_id = aws_security_group.workspace[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = "egress"

  # Optional
  description              = lookup(each.value, "description", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

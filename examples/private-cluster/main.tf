provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  name   = replace(basename(path.cwd), "-cluster", "")
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-emr"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EMR Module
################################################################################

module "emr_instance_fleet" {
  source = "../.."

  # create = false
  name = "${local.name}-instance-fleet"

  release_label_filters = {
    emr6 = {
      prefix = "emr-6"
    }
  }
  applications = ["spark", "trino"]
  auto_termination_policy = {
    idle_timeout = 3600
  }

  bootstrap_action = {
    example = {
      path = "file:/bin/echo",
      name = "Just an example",
      args = ["Hello World!"]
    }
  }

  configurations_json = jsonencode([
    {
      "Classification" : "spark-env",
      "Configurations" : [
        {
          "Classification" : "export",
          "Properties" : {
            "JAVA_HOME" : "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties" : {}
    }
  ])

  master_instance_fleet = {
    name                      = "master-fleet"
    target_on_demand_capacity = 1
    instance_type_configs = [
      {
        instance_type = "m5.xlarge"
      }
    ]
  }

  core_instance_fleet = {
    name                      = "core-fleet"
    target_on_demand_capacity = 2
    target_spot_capacity      = 2
    instance_type_configs = [
      {
        instance_type     = "c4.large"
        weighted_capacity = 1
      },
      {
        bid_price_as_percentage_of_on_demand_price = 100
        ebs_config = [{
          size                 = 256
          type                 = "gp3"
          volumes_per_instance = 1
        }]
        instance_type     = "c5.xlarge"
        weighted_capacity = 2
      },
      {
        bid_price_as_percentage_of_on_demand_price = 100
        instance_type                              = "c6i.xlarge"
        weighted_capacity                          = 2
      }
    ]
    launch_specifications = {
      spot_specification = {
        allocation_strategy      = "capacity-optimized"
        block_duration_minutes   = 0
        timeout_action           = "SWITCH_TO_ON_DEMAND"
        timeout_duration_minutes = 5
      }
    }
  }

  task_instance_fleet = {
    name                      = "task-fleet"
    target_on_demand_capacity = 1
    target_spot_capacity      = 2
    instance_type_configs = [
      {
        instance_type     = "c4.large"
        weighted_capacity = 1
      },
      {
        bid_price_as_percentage_of_on_demand_price = 100
        ebs_config = [{
          size                 = 256
          type                 = "gp3"
          volumes_per_instance = 1
        }]
        instance_type     = "c5.xlarge"
        weighted_capacity = 2
      }
    ]
    launch_specifications = {
      spot_specification = {
        allocation_strategy      = "capacity-optimized"
        block_duration_minutes   = 0
        timeout_action           = "SWITCH_TO_ON_DEMAND"
        timeout_duration_minutes = 5
      }
    }
  }

  ebs_root_volume_size = 64
  ec2_attributes = {
    subnet_ids = module.vpc.private_subnets
  }
  vpc_id = module.vpc.vpc_id

  keep_job_flow_alive_when_no_steps = true
  list_steps_states                 = ["PENDING", "RUNNING", "CANCEL_PENDING", "CANCELLED", "FAILED", "INTERRUPTED", "COMPLETED"]
  log_uri                           = "s3://${module.s3_bucket.s3_bucket_id}/"

  scale_down_behavior        = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level     = 3
  termination_protection     = false
  unhealthy_node_replacement = true
  visible_to_all_users       = true

  tags = local.tags
}

module "emr_instance_group" {
  source = "../.."

  name                        = "${local.name}-instance-group"
  create_iam_instance_profile = false
  create_autoscaling_iam_role = false

  release_label_filters = {
    emr6 = {
      prefix = "emr-6"
    }
  }
  applications = ["spark", "trino"]
  auto_termination_policy = {
    idle_timeout = 3600
  }

  bootstrap_action = {
    example = {
      name = "Just an example",
      path = "file:/bin/echo",
      args = ["Hello World!"]
    }
  }

  configurations_json = jsonencode([
    {
      "Classification" : "spark-env",
      "Configurations" : [
        {
          "Classification" : "export",
          "Properties" : {
            "JAVA_HOME" : "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties" : {}
    }
  ])

  #  Example placement group config for multiple primary node clusters
  #  placement_group_config = [
  #    {
  #      instance_role      = "MASTER"
  #      placement_strategy = "SPREAD"
  #    }
  #  ]

  master_instance_group = {
    name           = "master-group"
    instance_count = 1
    instance_type  = "m5.xlarge"
  }

  core_instance_group = {
    name           = "core-group"
    instance_count = 2
    instance_type  = "c4.large"
  }

  task_instance_group = {
    name           = "task-group"
    instance_count = 2
    instance_type  = "c5.xlarge"
    bid_price      = "0.1"

    ebs_config = [{
      size                 = 256
      type                 = "gp3"
      volumes_per_instance = 1
    }]
    ebs_optimized = true
  }

  ebs_root_volume_size = 64
  ec2_attributes = {
    # Instance groups only support one Subnet/AZ
    subnet_id        = element(module.vpc.private_subnets, 0)
    instance_profile = aws_iam_instance_profile.custom_instance_profile.arn
  }
  iam_instance_profile_role_arn = aws_iam_role.custom_instance_profile.arn
  autoscaling_iam_role_arn      = aws_iam_role.autoscaling.arn

  vpc_id = module.vpc.vpc_id

  keep_job_flow_alive_when_no_steps = true
  list_steps_states                 = ["PENDING", "RUNNING", "CANCEL_PENDING", "CANCELLED", "FAILED", "INTERRUPTED", "COMPLETED"]
  log_uri                           = "s3://${module.s3_bucket.s3_bucket_id}/"

  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level = 3
  termination_protection = false
  visible_to_all_users   = true

  tags = local.tags
}

module "emr_disabled" {
  source = "../.."

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
  # Tag if you want EMR to create the security groups for you
  # vpc_tags            = { "for-use-with-amazon-emr-managed-policies" = true }
  # Tag if you are using public subnets
  # public_subnet_tags  = { "for-use-with-amazon-emr-managed-policies" = true }
  private_subnet_tags = { "for-use-with-amazon-emr-managed-policies" = true }

  tags = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 6.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc_endpoints_sg.security_group_id]

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${local.name}-s3"
      }
    }
    },
    { for service in toset(["elasticmapreduce", "sts"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.vpc.private_subnets
        private_dns_enabled = true
        tags                = { Name = "${local.name}-${service}" }
      }
  })

  tags = local.tags
}

module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-vpc-endpoints"
  description = "Security group for VPC endpoint access"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "VPC CIDR HTTPS"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    },
  ]

  tags = local.tags
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket_prefix = "${local.name}-"

  # Allow deletion of non-empty bucket
  # Example usage only - not recommended for production
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "custom_instance_profile" {
  name_prefix        = "custom-instance-profile"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "emr_for_ec2" {
  role       = aws_iam_role.custom_instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "custom_instance_profile" {
  role = aws_iam_role.custom_instance_profile.name

  name = "custom-instance-profile"

  depends_on = [
    aws_iam_role_policy_attachment.emr_for_ec2,
  ]
}

resource "aws_iam_role" "autoscaling" {
  name_prefix        = "custom-autoscaling-role"
  assume_role_policy = data.aws_iam_policy_document.autoscaling.json
}

data "aws_iam_policy_document" "autoscaling" {
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
      values   = ["arn:aws:elasticmapreduce:${local.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "autoscaling" {
  role       = aws_iam_role.autoscaling.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

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
# Cluster
################################################################################

module "emr_serverless_spark" {
  source = "../../modules/serverless"

  name = "${local.name}-spark"

  release_label_prefix = "emr-6"

  initial_capacity = {
    driver = {
      initial_capacity_type = "Driver"

      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "4 vCPU"
          memory = "12 GB"
        }
      }
    }

    executor = {
      initial_capacity_type = "Executor"

      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "8 vCPU"
          disk   = "64 GB"
          memory = "24 GB"
        }
      }
    }
  }

  maximum_capacity = {
    cpu    = "48 vCPU"
    memory = "144 GB"
  }

  network_configuration = {
    subnet_ids = module.vpc.private_subnets
  }

  security_group_rules = {
    egress_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.tags
}

module "emr_serverless_hive" {
  source = "../../modules/serverless"

  name = "${local.name}-hive"

  release_label_prefix = "emr-6"
  type                 = "hive"

  initial_capacity = {
    driver = {
      initial_capacity_type = "HiveDriver"

      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "2 vCPU"
          memory = "6 GB"
        }
      }
    }

    task = {
      initial_capacity_type = "TezTask"

      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "4 vCPU"
          disk   = "32 GB"
          memory = "12 GB"
        }
      }
    }
  }

  maximum_capacity = {
    cpu    = "24 vCPU"
    memory = "72 GB"
  }

  tags = local.tags
}

module "emr_serverless_disabled" {
  source = "../../modules/serverless"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = local.tags
}

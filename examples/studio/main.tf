provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = replace(basename(path.cwd), "-cluster", "")
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-emr"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EMR Studio
################################################################################

data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_group" "this" {
  identity_store_id = one(data.aws_ssoadmin_instances.this.identity_store_ids)

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "AWSControlTowerAdmins"
    }
  }
}

module "emr_studio_complete" {
  source = "../../modules/studio"

  name                = "${local.name}-complete"
  description         = "EMR Studio using SSO authentication"
  auth_mode           = "SSO"
  default_s3_location = "s3://${module.s3_bucket.s3_bucket_id}/complete"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # SSO mapping
  session_mappings = {
    admin_group = {
      identity_type = "GROUP"
      identity_id   = data.aws_identitystore_group.this.group_id
    }
  }

  # Service role
  service_role_name        = "${local.name}-complete-service"
  service_role_path        = "/complete/"
  service_role_description = "EMR Studio complete service role"
  service_role_tags        = { service = true }
  service_role_s3_bucket_arns = [
    module.s3_bucket.s3_bucket_arn,
    "${module.s3_bucket.s3_bucket_arn}/complete/*}"
  ]

  # User role
  user_role_name        = "${local.name}-complete-user"
  user_role_path        = "/complete/"
  user_role_description = "EMR Studio complete user role"
  user_role_tags        = { user = true }
  user_role_s3_bucket_arns = [
    module.s3_bucket.s3_bucket_arn,
    "${module.s3_bucket.s3_bucket_arn}/complete/*}"
  ]

  # Security groups
  security_group_name = "${local.name}-complete"
  security_group_tags = { complete = true }

  # Engine security group
  engine_security_group_description = "EMR Studio complete engine security group"
  engine_security_group_rules = {
    example = {
      description = "Example egress to VPC network"
      type        = "egress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  # Workspace security group
  workspace_security_group_description = "EMR Studio complete workspace security group"
  workspace_security_group_rules = {
    example = {
      description = "Example egress to internet"
      type        = "egress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  tags = local.tags
}

module "emr_studio_sso" {
  source = "../../modules/studio"

  name                = "${local.name}-sso"
  description         = "EMR Studio using SSO authentication"
  auth_mode           = "SSO"
  default_s3_location = "s3://${module.s3_bucket.s3_bucket_id}/example"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # SSO Mapping
  session_mappings = {
    admin_group = {
      identity_type = "GROUP"
      identity_id   = data.aws_identitystore_group.this.group_id
    }
  }

  tags = local.tags
}

module "emr_studio_iam" {
  source = "../../modules/studio"

  name                = "${local.name}-iam"
  auth_mode           = "IAM"
  default_s3_location = "s3://${module.s3_bucket.s3_bucket_id}/example"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

module "emr_studio_disabled" {
  source = "../../modules/studio"

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

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> v3.0"

  bucket_prefix = "${local.name}-"

  # Allow deletion of non-empty bucket
  # Example usage only - not recommended for production
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name   = "virtual-emr"
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

module "complete" {
  source = "../../modules/virtual-cluster"

  eks_cluster_name      = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  name             = "emr-custom"
  create_namespace = true
  namespace        = "emr-custom"

  s3_bucket_arns = [
    module.s3_bucket.s3_bucket_arn,
    "${module.s3_bucket.s3_bucket_arn}/*"
  ]
  role_name                     = "emr-custom-role"
  iam_role_use_name_prefix      = false
  iam_role_path                 = "/"
  iam_role_description          = "EMR custom Role"
  iam_role_permissions_boundary = null
  iam_role_additional_policies  = []

  tags = local.tags
}

module "default" {
  source = "../../modules/virtual-cluster"

  eks_cluster_name      = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  s3_bucket_arns = [
    module.s3_bucket.s3_bucket_arn,
    "${module.s3_bucket.s3_bucket_arn}/*"
  ]

  name      = "emr-default"
  namespace = "emr-default"

  tags = local.tags
}

module "disabled" {
  source = "../../modules/virtual-cluster"

  create = false
}

################################################################################
# Sample Spark Job
################################################################################

resource "null_resource" "s3_sync" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    environment = {
      AWS_DEFAULT_REGION = local.region
    }

    # Sync to a bucket that we can provide access to (see `s3_bucket_arns` above)
    command = <<-EOT
      aws s3 sync s3://aws-data-analytics-workshops/emr-eks-workshop/scripts/ s3://${module.s3_bucket.s3_bucket_id}/emr-eks-workshop/scripts/
    EOT
  }
}

resource "null_resource" "start_job_run" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    environment = {
      AWS_DEFAULT_REGION = local.region
    }

    command = <<-EOT
      aws emr-containers start-job-run \
      --virtual-cluster-id ${module.complete.virtual_cluster_id} \
      --name ${local.name}-example \
      --execution-role-arn ${module.complete.job_execution_role_arn} \
      --release-label emr-7.9.0-latest \
      --job-driver '{
          "sparkSubmitJobDriver": {
              "entryPoint": "s3://${module.s3_bucket.s3_bucket_id}/emr-eks-workshop/scripts/pi.py",
              "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
              }
          }' \
      --configuration-overrides '{
          "applicationConfiguration": [
            {
              "classification": "spark-defaults",
              "properties": {
                "spark.driver.memory":"2G"
              }
            }
          ],
          "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
              "logGroupName": "${module.complete.cloudwatch_log_group_name}",
              "logStreamNamePrefix": "eks-blueprints"
            }
          }
        }'
    EOT
  }
}

################################################################################
# Supporting Resources
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                   = local.name
  kubernetes_version     = "1.33"
  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # Required for now until https://github.com/aws/containers-roadmap/issues/2397
  enable_irsa = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose", "system"]
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Auto Mode uses the cluster primary security group so these are not utilized
  create_security_group      = false
  create_node_security_group = false

  tags = local.tags
}

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

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 6.0"

  vpc_id = module.vpc.vpc_id

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
    { for service in toset(["emr-containers", "ecr.api", "ecr.dkr", "sts", "logs"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.vpc.private_subnets
        private_dns_enabled = true
        tags                = { Name = "${local.name}-${service}" }
      }
  })

  # Security group
  create_security_group = true
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from private subnets"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    }
  }

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

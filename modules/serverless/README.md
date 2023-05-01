# AWS EMR Serverless Terraform module

Terraform module which creates AWS EMR Serverless resources.

## Usage

See [`examples`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples) directory for working examples to reference:

### Spark Cluster

```hcl
module "emr_serverless" {
  source = "terraform-aws-modules/emr/aws//modules/serverless"

  name = "example-spark"

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
    subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  }

  security_group_rules = {
    egress_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### Hive Cluster

```hcl
module "emr_serverless" {
  source = "terraform-aws-modules/emr/aws//modules/serverless"

  name = "example-hive"

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

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Examples

Examples codified under the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples) are intended to give users references for how to use the module(s) as well as testing/validating changes to the source code of the module. If contributing to the project, please be sure to make any appropriate updates to the relevant examples to allow maintainers to test your changes and to keep the examples up to date for users. Thank you!

- [Private clusters](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/private-cluster) using instance fleet or instance group
- [Public clusters](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/private-cluster) using instance fleet or instance group
- [Serverless clusters](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/virtual-cluster) running Spark or Hive
- [Studios](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/studio) with either IAM or SSO authentication
- [Virtual cluster](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/virtual-cluster) running on Amazon EKS

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.62 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_emrserverless_application.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emrserverless_application) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_emr_release_labels.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/emr_release_labels) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The CPU architecture of an application. Valid values are `ARM64` or `X86_64`. Default value is `X86_64` | `string` | `null` | no |
| <a name="input_auto_start_configuration"></a> [auto\_start\_configuration](#input\_auto\_start\_configuration) | The configuration for an application to automatically start on job submission | `any` | `{}` | no |
| <a name="input_auto_stop_configuration"></a> [auto\_stop\_configuration](#input\_auto\_stop\_configuration) | The configuration for an application to automatically stop after a certain amount of time being idle | `any` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines whether the security group is created | `bool` | `true` | no |
| <a name="input_image_configuration"></a> [image\_configuration](#input\_image\_configuration) | The image configuration applied to all worker types | `any` | `{}` | no |
| <a name="input_initial_capacity"></a> [initial\_capacity](#input\_initial\_capacity) | The capacity to initialize when the application is created | `any` | `{}` | no |
| <a name="input_maximum_capacity"></a> [maximum\_capacity](#input\_maximum\_capacity) | The maximum capacity to allocate when the application is created. This is cumulative across all workers at any given point in time, not just when an application is created. No new resources will be created once any one of the defined limits is hit | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the application | `string` | `""` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | The network configuration for customer VPC connectivity | `any` | `{}` | no |
| <a name="input_release_label"></a> [release\_label](#input\_release\_label) | Release label for the Amazon EMR release | `string` | `null` | no |
| <a name="input_release_label_prefix"></a> [release\_label\_prefix](#input\_release\_label\_prefix) | Release label prefix used to lookup a release label | `string` | `"emr-6"` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to add to the security group created | `any` | `{}` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of application you want to start, such as `spark` or `hive`. Defaults to `spark` | `string` | `"spark"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the application |
| <a name="output_id"></a> [id](#output\_id) | ID of the application |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

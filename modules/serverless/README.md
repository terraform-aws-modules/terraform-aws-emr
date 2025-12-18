# AWS EMR Serverless Terraform module

Terraform module which creates AWS EMR Serverless resources.

## Usage

See [`examples`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples) directory for working examples to reference:

### Spark Cluster

```hcl
module "emr_serverless" {
  source = "terraform-aws-modules/emr/aws//modules/serverless"

  name = "example-spark"

  release_label_prefix = "emr-7"

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

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4 = "0.0.0.0/0"
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

  release_label_prefix = "emr-7"
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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.27 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_emrserverless_application.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emrserverless_application) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_emr_release_labels.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/emr_release_labels) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The CPU architecture of an application. Valid values are `ARM64` or `X86_64`. Default value is `X86_64` | `string` | `null` | no |
| <a name="input_auto_start_configuration"></a> [auto\_start\_configuration](#input\_auto\_start\_configuration) | The configuration for an application to automatically start on job submission | <pre>object({<br/>    enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_auto_stop_configuration"></a> [auto\_stop\_configuration](#input\_auto\_stop\_configuration) | The configuration for an application to automatically stop after a certain amount of time being idle | <pre>object({<br/>    enabled              = optional(bool)<br/>    idle_timeout_minutes = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines whether the security group is created | `bool` | `true` | no |
| <a name="input_image_configuration"></a> [image\_configuration](#input\_image\_configuration) | The image configuration applied to all worker types | <pre>object({<br/>    image_uri = string<br/>  })</pre> | `null` | no |
| <a name="input_initial_capacity"></a> [initial\_capacity](#input\_initial\_capacity) | The capacity to initialize when the application is created | <pre>map(object({<br/>    initial_capacity_config = optional(object({<br/>      worker_configuration = optional(object({<br/>        cpu    = string<br/>        disk   = optional(string)<br/>        memory = string<br/>      }))<br/>      worker_count = optional(number, 1)<br/>    }))<br/>    initial_capacity_type = string<br/>  }))</pre> | `null` | no |
| <a name="input_interactive_configuration"></a> [interactive\_configuration](#input\_interactive\_configuration) | Enables the interactive use cases to use when running an application | <pre>object({<br/>    livy_endpoint_enabled = optional(bool)<br/>    studio_enabled        = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_maximum_capacity"></a> [maximum\_capacity](#input\_maximum\_capacity) | The maximum capacity to allocate when the application is created. This is cumulative across all workers at any given point in time, not just when an application is created. No new resources will be created once any one of the defined limits is hit | <pre>object({<br/>    cpu    = string<br/>    disk   = optional(string)<br/>    memory = string<br/>  })</pre> | `null` | no |
| <a name="input_monitoring_configuration"></a> [monitoring\_configuration](#input\_monitoring\_configuration) | The monitoring configuration for the application | <pre>object({<br/>    cloudwatch_logging_configuration = optional(object({<br/>      enabled                = optional(bool)<br/>      log_group_name         = optional(string)<br/>      log_stream_name_prefix = optional(string)<br/>      encryption_key_arn     = optional(string)<br/>      log_types = optional(list(object({<br/>        name   = string<br/>        values = list(string)<br/>      })))<br/>    }))<br/>    managed_persistence_monitoring_configuration = optional(object({<br/>      enabled            = optional(bool)<br/>      encryption_key_arn = optional(string)<br/>    }))<br/>    prometheus_monitoring_configuration = optional(object({<br/>      remote_write_url = optional(string)<br/>    }))<br/>    s3_monitoring_configuration = optional(object({<br/>      log_uri            = optional(string)<br/>      encryption_key_arn = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the application | `string` | `""` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | The network configuration for customer VPC connectivity | <pre>object({<br/>    security_group_ids = optional(list(string), [])<br/>    subnet_ids         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_release_label"></a> [release\_label](#input\_release\_label) | Release label for the Amazon EMR release | `string` | `null` | no |
| <a name="input_release_label_filters"></a> [release\_label\_filters](#input\_release\_label\_filters) | Map of release label filters use to lookup a release label | <pre>map(object({<br/>    application = optional(string)<br/>    prefix      = optional(string)<br/>  }))</pre> | <pre>{<br/>  "default": {<br/>    "prefix": "emr-7"<br/>  }<br/>}</pre> | no |
| <a name="input_runtime_configuration"></a> [runtime\_configuration](#input\_runtime\_configuration) | The runtime configuration for the application | <pre>list(object({<br/>    classification = string<br/>    properties     = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_scheduler_configuration"></a> [scheduler\_configuration](#input\_scheduler\_configuration) | The scheduler configuration for the application | <pre>object({<br/>    max_concurrent_runs   = optional(number)<br/>    queue_timeout_minutes = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Security group egress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | <pre>{<br/>  "all-traffic": {<br/>    "cidr_ipv4": "0.0.0.0/0",<br/>    "description": "Allow all egress traffic",<br/>    "ip_protocol": "-1"<br/>  }<br/>}</pre> | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Security group ingress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
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
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

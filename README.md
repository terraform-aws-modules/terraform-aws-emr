# AWS EMR Terraform module

Terraform module which creates AWS EMR resources.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

This module supports the creation of:
- EMR clusters using instance fleets or instance groups deployed in public or private subnets
- EMR Virtual clusters that run on Amazon EKS
- EMR Serverless clusters
- EMR Studios
- Security groups for `master`, `core`, and `task` nodes
- Security group for EMR `service` to support private clusters
- IAM roles for autoscaling, EMR `service`, and EC2 instance profiles

  :information_source: The appropriate resources have been tagged with `{ "for-use-with-amazon-emr-managed-policies" = true }` to support the use of the recommended IAM policy `"arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"`. Users are required to tag the appropriate VPC resources (VPC and subnets) as needed. See [here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html) for more details regarding v2 of managed EMR policies and their usage requirements.

## Usage

### Private Cluster w/ Instance Fleet

```hcl
module "emr" {
  source = "terraform-aws-modules/emr/aws"

  name = "example-instance-fleet"

  release_label = "emr-6.9.0"
  applications  = ["spark", "trino"]
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
    # Subnets should be private subnets and tagged with
    # { "for-use-with-amazon-emr-managed-policies" = true }
    subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  }
  vpc_id = "vpc-1234556abcdef"

  list_steps_states  = ["PENDING", "RUNNING", "FAILED", "INTERRUPTED"]
  log_uri            = "s3://my-elasticmapreduce-bucket/"

  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level = 3
  termination_protection = false
  visible_to_all_users   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### Public Cluster w/ Instance Fleet

Configuration is the same as the public version shown above except for the following changes noted below. Users should utilize S3 and EMR VPC endpoints for private connectivity and avoid data transfer charges across NAT gateways.

```hcl
...
  ec2_attributes = {
    # Subnets should be public subnets and tagged with
    # { "for-use-with-amazon-emr-managed-policies" = true }
    subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]
  }

  # Required for creating public cluster
  is_private_cluster = false
...
```

### Private Cluster w/ Instance Group

```hcl
module "emr" {
  source = "terraform-aws-modules/emr/aws"

  name = "example-instance-group"

  release_label = "emr-6.9.0"
  applications  = ["spark", "trino"]
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
    # Subnets should be private subnets and tagged with
    # { "for-use-with-amazon-emr-managed-policies" = true }
    subnet_id = "subnet-abcde012"
  }
  vpc_id = "vpc-1234556abcdef"

  list_steps_states  = ["PENDING", "RUNNING", "FAILED", "INTERRUPTED"]
  log_uri            = "s3://my-elasticmapreduce-bucket/"

  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level = 3
  termination_protection = false
  visible_to_all_users   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### Public Cluster w/ Instance Group

Configuration is the same as the public version shown above except for the following changes noted below. Users should utilize S3 and EMR VPC endpoints for private connectivity and avoid data transfer charges across NAT gateways.

```hcl
...
  ec2_attributes = {
    # Instance groups only support one Subnet/AZ
    # Subnets should be public subnets and tagged with
    # { "for-use-with-amazon-emr-managed-policies" = true }
    subnet_id = "subnet-xyzde987"
  }

  # Required for creating public cluster
  is_private_cluster = false
...
```

## Conditional Creation

The following values are provided to toggle on/off creation of the associated resources as desired:

```hcl
module "emr" {
  source = "terraform-aws-modules/emr/aws"

  # Disables all resources from being created
  create = false

  # Enables the creation of a security configuration for the cluster
  # Configuration should be supplied via the `security_configuration` variable
  create_security_configuration = true

  # Disables the creation of the role used by the service
  # An externally created role must be supplied via the `service_iam_role_arn` variable
  create_service_iam_role = false

  # Disables the creation of the role used by the service
  # An externally created role can be supplied via the `autoscaling_iam_role_arn` variable
  create_autoscaling_iam_role = false

  # Disables the creation of the IAM role/instance profile used by the EC2 instances
  # An externally created IAM instance profile must be supplied
  # via the `iam_instance_profile_name` variable
  create_iam_instance_profile = false

  # Disables the creation of the security groups used by the EC2 instances. Users can supplied
  # security groups for `master`, `slave`, and `service` security groups via the
  # `ec2_attributes` map variable. If not, the EMR service will create and associate
  # the necessary security groups. Note - the VPC will need to be tagged with
  # { "for-use-with-amazon-emr-managed-policies" = true } for EMR to create security groups
  # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html
  create_managed_security_groups = false

  is_private_cluster = false
}
```

## Examples

Examples codified under the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples) are intended to give users references for how to use the module(s) as well as testing/validating changes to the source code of the module. If contributing to the project, please be sure to make any appropriate updates to the relevant examples to allow maintainers to test your changes and to keep the examples up to date for users. Thank you!

- [Private clusters](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/private-cluster) using instance fleet or instance group
- [Public clusters](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/public-cluster) using instance fleet or instance group
- [Serverless clusters](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/serverless-cluster) running Spark or Hive
- [Studios](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/studio) with either IAM or SSO authentication
- [Virtual cluster](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples/virtual-cluster) running on Amazon EKS

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.65 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_emr_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster) | resource |
| [aws_emr_instance_fleet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_instance_fleet) | resource |
| [aws_emr_instance_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_instance_group) | resource |
| [aws_emr_managed_scaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_managed_scaling_policy) | resource |
| [aws_emr_security_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_security_configuration) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.service_pass_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service_pass_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.slave](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.slave](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_emr_release_labels.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/emr_release_labels) | data source |
| [aws_iam_policy_document.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_pass_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_info"></a> [additional\_info](#input\_additional\_info) | JSON string for selecting additional features such as adding proxy information. Note: Currently there is no API to retrieve the value of this argument after EMR cluster creation from provider, therefore Terraform cannot detect drift from the actual EMR cluster if its value is changed outside Terraform | `string` | `null` | no |
| <a name="input_applications"></a> [applications](#input\_applications) | A case-insensitive list of applications for Amazon EMR to install and configure when launching the cluster | `list(string)` | `[]` | no |
| <a name="input_auto_termination_policy"></a> [auto\_termination\_policy](#input\_auto\_termination\_policy) | An auto-termination policy for an Amazon EMR cluster. An auto-termination policy defines the amount of idle time in seconds after which a cluster automatically terminates | `any` | `{}` | no |
| <a name="input_autoscaling_iam_role_arn"></a> [autoscaling\_iam\_role\_arn](#input\_autoscaling\_iam\_role\_arn) | The ARN of an existing IAM role to use for autoscaling | `string` | `null` | no |
| <a name="input_autoscaling_iam_role_description"></a> [autoscaling\_iam\_role\_description](#input\_autoscaling\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_autoscaling_iam_role_name"></a> [autoscaling\_iam\_role\_name](#input\_autoscaling\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_bootstrap_action"></a> [bootstrap\_action](#input\_bootstrap\_action) | Ordered list of bootstrap actions that will be run before Hadoop is started on the cluster nodes | `any` | `{}` | no |
| <a name="input_configurations"></a> [configurations](#input\_configurations) | List of configurations supplied for the EMR cluster you are creating. Supply a configuration object for applications to override their default configuration | `string` | `null` | no |
| <a name="input_configurations_json"></a> [configurations\_json](#input\_configurations\_json) | JSON string for supplying list of configurations for the EMR cluster | `string` | `null` | no |
| <a name="input_core_instance_fleet"></a> [core\_instance\_fleet](#input\_core\_instance\_fleet) | Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the core node type. Cannot be specified if any `core_instance_group` configuration blocks are set | `any` | `{}` | no |
| <a name="input_core_instance_group"></a> [core\_instance\_group](#input\_core\_instance\_group) | Configuration block to use an [Instance Group] for the core node type | `any` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_autoscaling_iam_role"></a> [create\_autoscaling\_iam\_role](#input\_create\_autoscaling\_iam\_role) | Determines whether the autoscaling IAM role should be created | `bool` | `true` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Determines whether the EC2 IAM role/instance profile should be created | `bool` | `true` | no |
| <a name="input_create_managed_security_groups"></a> [create\_managed\_security\_groups](#input\_create\_managed\_security\_groups) | Determines whether managed security groups are created | `bool` | `true` | no |
| <a name="input_create_security_configuration"></a> [create\_security\_configuration](#input\_create\_security\_configuration) | Determines whether a security configuration is created | `bool` | `false` | no |
| <a name="input_create_service_iam_role"></a> [create\_service\_iam\_role](#input\_create\_service\_iam\_role) | Determines whether the service IAM role should be created | `bool` | `true` | no |
| <a name="input_custom_ami_id"></a> [custom\_ami\_id](#input\_custom\_ami\_id) | Custom Amazon Linux AMI for the cluster (instead of an EMR-owned AMI). Available in Amazon EMR version 5.7.0 and later | `string` | `null` | no |
| <a name="input_ebs_root_volume_size"></a> [ebs\_root\_volume\_size](#input\_ebs\_root\_volume\_size) | Size in GiB of the EBS root device volume of the Linux AMI that is used for each EC2 instance. Available in Amazon EMR version 4.x and later | `number` | `null` | no |
| <a name="input_ec2_attributes"></a> [ec2\_attributes](#input\_ec2\_attributes) | Attributes for the EC2 instances running the job flow | `any` | `{}` | no |
| <a name="input_iam_instance_profile_description"></a> [iam\_instance\_profile\_description](#input\_iam\_instance\_profile\_description) | Description of the EC2 IAM role/instance profile | `string` | `null` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name to use on EC2 IAM role/instance profile created | `string` | `null` | no |
| <a name="input_iam_instance_profile_policies"></a> [iam\_instance\_profile\_policies](#input\_iam\_instance\_profile\_policies) | Map of IAM policies to attach to the EC2 IAM role/instance profile | `map(string)` | <pre>{<br>  "AmazonElasticMapReduceforEC2Role": "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"<br>}</pre> | no |
| <a name="input_iam_instance_profile_role_arn"></a> [iam\_instance\_profile\_role\_arn](#input\_iam\_instance\_profile\_role\_arn) | The role associated with the ec2 instance profile if specifying a custom instance profile | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name is used as a prefix | `bool` | `true` | no |
| <a name="input_is_private_cluster"></a> [is\_private\_cluster](#input\_is\_private\_cluster) | Identifies whether the cluster is created in a private subnet | `bool` | `true` | no |
| <a name="input_keep_job_flow_alive_when_no_steps"></a> [keep\_job\_flow\_alive\_when\_no\_steps](#input\_keep\_job\_flow\_alive\_when\_no\_steps) | Switch on/off run cluster with no steps or when all steps are complete (default is on) | `bool` | `null` | no |
| <a name="input_kerberos_attributes"></a> [kerberos\_attributes](#input\_kerberos\_attributes) | Kerberos configuration for the cluster | `any` | `{}` | no |
| <a name="input_list_steps_states"></a> [list\_steps\_states](#input\_list\_steps\_states) | List of [step states](https://docs.aws.amazon.com/emr/latest/APIReference/API_StepStatus.html) used to filter returned steps | `list(string)` | `[]` | no |
| <a name="input_log_encryption_kms_key_id"></a> [log\_encryption\_kms\_key\_id](#input\_log\_encryption\_kms\_key\_id) | AWS KMS customer master key (CMK) key ID or arn used for encrypting log files. This attribute is only available with EMR version 5.30.0 and later, excluding EMR 6.0.0 | `string` | `null` | no |
| <a name="input_log_uri"></a> [log\_uri](#input\_log\_uri) | S3 bucket to write the log files of the job flow. If a value is not provided, logs are not created | `string` | `null` | no |
| <a name="input_managed_scaling_policy"></a> [managed\_scaling\_policy](#input\_managed\_scaling\_policy) | Compute limit configuration for a [Managed Scaling Policy](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-scaling.html) | `any` | `{}` | no |
| <a name="input_managed_security_group_name"></a> [managed\_security\_group\_name](#input\_managed\_security\_group\_name) | Name to use on manged security group created. Note - `-master`, `-slave`, and `-service` will be appended to this name to distinguish | `string` | `null` | no |
| <a name="input_managed_security_group_tags"></a> [managed\_security\_group\_tags](#input\_managed\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_managed_security_group_use_name_prefix"></a> [managed\_security\_group\_use\_name\_prefix](#input\_managed\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_master_instance_fleet"></a> [master\_instance\_fleet](#input\_master\_instance\_fleet) | Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the master node type. Cannot be specified if any `master_instance_group` configuration blocks are set | `any` | `{}` | no |
| <a name="input_master_instance_group"></a> [master\_instance\_group](#input\_master\_instance\_group) | Configuration block to use an [Instance Group](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-group-configuration.html#emr-plan-instance-groups) for the [master node type](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html#emr-plan-master) | `any` | `{}` | no |
| <a name="input_master_security_group_description"></a> [master\_security\_group\_description](#input\_master\_security\_group\_description) | Description of the security group created | `string` | `"Managed master security group"` | no |
| <a name="input_master_security_group_rules"></a> [master\_security\_group\_rules](#input\_master\_security\_group\_rules) | Security group rules to add to the security group created | `any` | <pre>{<br>  "default": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow all egress traffic",<br>    "from_port": 0,<br>    "ipv6_cidr_blocks": [<br>      "::/0"<br>    ],<br>    "protocol": "-1",<br>    "to_port": 0,<br>    "type": "egress"<br>  }<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the job flow | `string` | `""` | no |
| <a name="input_placement_group_config"></a> [placement\_group\_config](#input\_placement\_group\_config) | The specified placement group configuration | `any` | `{}` | no |
| <a name="input_release_label"></a> [release\_label](#input\_release\_label) | Release label for the Amazon EMR release | `string` | `null` | no |
| <a name="input_release_label_filters"></a> [release\_label\_filters](#input\_release\_label\_filters) | Map of release label filters use to lookup a release label | `any` | <pre>{<br>  "default": {<br>    "prefix": "emr-6"<br>  }<br>}</pre> | no |
| <a name="input_scale_down_behavior"></a> [scale\_down\_behavior](#input\_scale\_down\_behavior) | Way that individual Amazon EC2 instances terminate when an automatic scale-in activity occurs or an instance group is resized | `string` | `"TERMINATE_AT_TASK_COMPLETION"` | no |
| <a name="input_security_configuration"></a> [security\_configuration](#input\_security\_configuration) | Security configuration to create, or attach if `create_security_configuration` is `false`. Only valid for EMR clusters with `release_label` 4.8.0 or greater | `string` | `null` | no |
| <a name="input_security_configuration_name"></a> [security\_configuration\_name](#input\_security\_configuration\_name) | Name of the security configuration to create, or attach if `create_security_configuration` is `false`. Only valid for EMR clusters with `release_label` 4.8.0 or greater | `string` | `null` | no |
| <a name="input_security_configuration_use_name_prefix"></a> [security\_configuration\_use\_name\_prefix](#input\_security\_configuration\_use\_name\_prefix) | Determines whether `security_configuration_name` is used as a prefix | `bool` | `true` | no |
| <a name="input_service_iam_role_arn"></a> [service\_iam\_role\_arn](#input\_service\_iam\_role\_arn) | The ARN of an existing IAM role to use for the service | `string` | `null` | no |
| <a name="input_service_iam_role_description"></a> [service\_iam\_role\_description](#input\_service\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_service_iam_role_name"></a> [service\_iam\_role\_name](#input\_service\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_service_iam_role_policies"></a> [service\_iam\_role\_policies](#input\_service\_iam\_role\_policies) | Map of IAM policies to attach to the service role | `map(string)` | <pre>{<br>  "AmazonEMRServicePolicy_v2": "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"<br>}</pre> | no |
| <a name="input_service_pass_role_policy_description"></a> [service\_pass\_role\_policy\_description](#input\_service\_pass\_role\_policy\_description) | Description of the policy | `string` | `null` | no |
| <a name="input_service_pass_role_policy_name"></a> [service\_pass\_role\_policy\_name](#input\_service\_pass\_role\_policy\_name) | Name to use on IAM policy created | `string` | `null` | no |
| <a name="input_service_security_group_description"></a> [service\_security\_group\_description](#input\_service\_security\_group\_description) | Description of the security group created | `string` | `"Managed service access security group"` | no |
| <a name="input_service_security_group_rules"></a> [service\_security\_group\_rules](#input\_service\_security\_group\_rules) | Security group rules to add to the security group created | `any` | `{}` | no |
| <a name="input_slave_security_group_description"></a> [slave\_security\_group\_description](#input\_slave\_security\_group\_description) | Description of the security group created | `string` | `"Managed slave security group"` | no |
| <a name="input_slave_security_group_rules"></a> [slave\_security\_group\_rules](#input\_slave\_security\_group\_rules) | Security group rules to add to the security group created | `any` | <pre>{<br>  "default": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow all egress traffic",<br>    "from_port": 0,<br>    "ipv6_cidr_blocks": [<br>      "::/0"<br>    ],<br>    "protocol": "-1",<br>    "to_port": 0,<br>    "type": "egress"<br>  }<br>}</pre> | no |
| <a name="input_step"></a> [step](#input\_step) | Steps to run when creating the cluster | `any` | `{}` | no |
| <a name="input_step_concurrency_level"></a> [step\_concurrency\_level](#input\_step\_concurrency\_level) | Number of steps that can be executed concurrently. You can specify a maximum of 256 steps. Only valid for EMR clusters with `release_label` 5.28.0 or greater (default is 1) | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_instance_fleet"></a> [task\_instance\_fleet](#input\_task\_instance\_fleet) | Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the task node type. Cannot be specified if any `task_instance_group` configuration blocks are set | `any` | `{}` | no |
| <a name="input_task_instance_group"></a> [task\_instance\_group](#input\_task\_instance\_group) | Configuration block to use an [Instance Group](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-group-configuration.html#emr-plan-instance-groups) for the [task node type](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html#emr-plan-master) | `any` | `{}` | no |
| <a name="input_termination_protection"></a> [termination\_protection](#input\_termination\_protection) | Switch on/off termination protection (default is `false`, except when using multiple master nodes). Before attempting to destroy the resource when termination protection is enabled, this configuration must be applied with its value set to `false` | `bool` | `null` | no |
| <a name="input_unhealthy_node_replacement"></a> [unhealthy\_node\_replacement](#input\_unhealthy\_node\_replacement) | Whether whether Amazon EMR should gracefully replace core nodes that have degraded within the cluster. Default value is `false` | `bool` | `null` | no |
| <a name="input_visible_to_all_users"></a> [visible\_to\_all\_users](#input\_visible\_to\_all\_users) | Whether the job flow is visible to all IAM users of the AWS account associated with the job flow. Default value is `true` | `bool` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the Amazon Virtual Private Cloud (Amazon VPC) where the security groups will be created | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_iam_role_arn"></a> [autoscaling\_iam\_role\_arn](#output\_autoscaling\_iam\_role\_arn) | Autoscaling IAM role ARN |
| <a name="output_autoscaling_iam_role_name"></a> [autoscaling\_iam\_role\_name](#output\_autoscaling\_iam\_role\_name) | Autoscaling IAM role name |
| <a name="output_autoscaling_iam_role_unique_id"></a> [autoscaling\_iam\_role\_unique\_id](#output\_autoscaling\_iam\_role\_unique\_id) | Stable and unique string identifying the autoscaling IAM role |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the cluster |
| <a name="output_cluster_core_instance_group_id"></a> [cluster\_core\_instance\_group\_id](#output\_cluster\_core\_instance\_group\_id) | Core node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the cluster |
| <a name="output_cluster_master_instance_group_id"></a> [cluster\_master\_instance\_group\_id](#output\_cluster\_master\_instance\_group\_id) | Master node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_cluster_master_public_dns"></a> [cluster\_master\_public\_dns](#output\_cluster\_master\_public\_dns) | The DNS name of the master node. If the cluster is on a private subnet, this is the private DNS name. On a public subnet, this is the public DNS name |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_iam_instance_profile_iam_role_arn"></a> [iam\_instance\_profile\_iam\_role\_arn](#output\_iam\_instance\_profile\_iam\_role\_arn) | Instance profile IAM role ARN |
| <a name="output_iam_instance_profile_iam_role_name"></a> [iam\_instance\_profile\_iam\_role\_name](#output\_iam\_instance\_profile\_iam\_role\_name) | Instance profile IAM role name |
| <a name="output_iam_instance_profile_iam_role_unique_id"></a> [iam\_instance\_profile\_iam\_role\_unique\_id](#output\_iam\_instance\_profile\_iam\_role\_unique\_id) | Stable and unique string identifying the instance profile IAM role |
| <a name="output_iam_instance_profile_id"></a> [iam\_instance\_profile\_id](#output\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_iam_instance_profile_unique"></a> [iam\_instance\_profile\_unique](#output\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_managed_master_security_group_arn"></a> [managed\_master\_security\_group\_arn](#output\_managed\_master\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed master security group |
| <a name="output_managed_master_security_group_id"></a> [managed\_master\_security\_group\_id](#output\_managed\_master\_security\_group\_id) | ID of the managed master security group |
| <a name="output_managed_service_access_security_group_arn"></a> [managed\_service\_access\_security\_group\_arn](#output\_managed\_service\_access\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed service access security group |
| <a name="output_managed_service_access_security_group_id"></a> [managed\_service\_access\_security\_group\_id](#output\_managed\_service\_access\_security\_group\_id) | ID of the managed service access security group |
| <a name="output_managed_slave_security_group_arn"></a> [managed\_slave\_security\_group\_arn](#output\_managed\_slave\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed slave security group |
| <a name="output_managed_slave_security_group_id"></a> [managed\_slave\_security\_group\_id](#output\_managed\_slave\_security\_group\_id) | ID of the managed slave security group |
| <a name="output_security_configuration_id"></a> [security\_configuration\_id](#output\_security\_configuration\_id) | The ID of the security configuration |
| <a name="output_security_configuration_name"></a> [security\_configuration\_name](#output\_security\_configuration\_name) | The name of the security configuration |
| <a name="output_service_iam_role_arn"></a> [service\_iam\_role\_arn](#output\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_service_iam_role_name"></a> [service\_iam\_role\_name](#output\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_service_iam_role_unique_id"></a> [service\_iam\_role\_unique\_id](#output\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

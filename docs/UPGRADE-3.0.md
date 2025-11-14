# Upgrade from v2.x to v3.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples) directory:
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform `v1.5.7` is now minimum supported version
- AWS provider `v6.19` is now minimum supported version
- Kubernetes provider `v2.38` is now minimum supported version (EMR on EKS virtual cluster sub-module)
- `aws_security_group_rule` resources have been split into `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources to better match the AWS API and allow for more flexibility in defining security group rules. Prior variable names of `*_security_group_rules` have been split into `*_security_group_ingress_rules` and `*_security_group_egress_rules` to match.

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.
- Ensure data sources are gated behind `create` flags to prevent unnecessary API calls.
- `release_label_filters.prefix` now defaults to `emr-7`, was previously `emr-6`.
- `unhealthy_node_replacement` now defaults to `true`
- `aws_service_principal` data source is now used to fetch the correct service principals (instead of trying to construct them psuedo-manually with the DNS suffix).

### Variable and output changes

1. Removed variables:

    - `serverless` sub-module
      - None

    - `studio` sub-module
      - None

    - `virtual_cluster` sub-module

2. Renamed variables:

    - `master_security_group_rules` -> `master_security_group_ingress_rules` and `master_security_group_egress_rules`
    - `slave_security_group_rules` -> `slave_security_group_ingress_rules` and `slave_security_group_egress_rules`
    - `service_security_group_rules` -> `service_security_group_ingress_rules` and `service_security_group_egress_rules`

    - `serverless` sub-module
      - `security_group_rules` -> `security_group_ingress_rules` and `security_group_egress_rules`
      - `release_label_prefix` -> `release_label_filters`

    - `studio` sub-module
      - `engine_security_group_rules` -> `engine_security_group_ingress_rules` and `engine_security_group_egress_rules`
      - `workspace_security_group_rules` -> `workspace_security_group_ingress_rules` and `workspace_security_group_egress_rules`

    - `virtual_cluster` sub-module
      - `eks_cluster_id` -> `eks_cluster_name` to better match API of EKS module/resources
      - `oidc_provider_arn` -> `eks_oidc_provider_arn` for clarity to show its related to EKS authentication

3. Added variables:

    - `os_release_label`

    - `serverless` sub-module
      - `monitoring_configuration`
      - `runtime_configuration`
      - `scheduler_configuration`

    - `studio` sub-module
      - None

    - `virtual_cluster` sub-module
      - `cloudwatch_log_group_class`

4. Removed outputs:

    - `serverless` sub-module
      - None

    - `studio` sub-module
      - None

    - `virtual_cluster` sub-module

5. Renamed outputs:

    - `serverless` sub-module
      - None

    - `studio` sub-module
      - None

    - `virtual_cluster` sub-module
      - None

6. Added outputs:

    - `serverless` sub-module
      - None

    - `studio` sub-module
      - None

    - `virtual_cluster` sub-module
      - None

## Upgrade Migration

### Before v2.x Example

```hcl
module "emr" {
  source  = "terraform-aws-modules/emr/aws"
  version = "~> 2.0"

  # Only the affected attributes are shown

  bootstrap_action = {
    example = {
      name = "Just an example",
      path = "file:/bin/echo",
      args = ["Hello World!"]
    }
  }
}
```

### After v3.x Example

```hcl
module "emr" {
  source  = "terraform-aws-modules/emr/aws"
  version = "~> 2.0"

  # Only the affected attributes are shown

  # Copy and paste from output to maintain backwards compatibility
  # This was added by the AWS Redshift API and provider in v6.x
  os_release_label = "2023.9.20251014.0"

  bootstrap_action = [
    {
      name = "Just an example",
      path = "file:/bin/echo",
      args = ["Hello World!"]
    }
  ]
}
```

### State Changes

Due to the change from `aws_security_group_rule` to `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`, the following reference state changes are required to maintain the current security group rules. (Note: these are different resources so they cannot be moved with `terraform mv ...`)

#### Instance Group

```sh
# Master Security Group
terraform state rm 'module.emr_instance_group.aws_security_group_rule.master["default"]'
terraform state import 'module.emr_instance_group.aws_vpc_security_group_egress_rule.master["all-traffic"]' 'sg-xxx'

# Slave Security Group
terraform state rm 'module.emr_instance_group.aws_security_group_rule.slave["default"]'
terraform state import 'module.emr_instance_group.aws_vpc_security_group_egress_rule.slave["all-traffic"]' 'sg-xxx'

# Service Security Group
terraform state rm 'module.emr_instance_group.aws_security_group_rule.service["master_9443_ingress"]'
terraform state import 'module.emr_instance_group.aws_vpc_security_group_ingress_rule.service["master_9443"]' 'sg-xxx'

terraform state rm 'module.emr_instance_group.aws_security_group_rule.service["master_9443_egress"]'
terraform state import 'module.emr_instance_group.aws_vpc_security_group_egress_rule.service["master_8443"]' 'sg-xxx'

terraform state rm 'module.emr_instance_group.aws_security_group_rule.service["core_task_8443_egress"]'
terraform state import 'module.emr_instance_group.aws_vpc_security_group_egress_rule.service["core_task_8443"]' 'sg-xxx'
```

#### Instance Fleet

```sh
# Master Security Group
terraform state rm 'module.emr_instance_fleet.aws_security_group_rule.master["default"]'
terraform state import 'module.emr_instance_fleet.aws_vpc_security_group_egress_rule.master["all-traffic"]' 'sg-xxx'

# Slave Security Group
terraform state rm 'module.emr_instance_fleet.aws_security_group_rule.slave["default"]'
terraform state import 'module.emr_instance_fleet.aws_vpc_security_group_egress_rule.slave["all-traffic"]' 'sg-xxx'

# Service Security Group
terraform state rm 'module.emr_instance_fleet.aws_security_group_rule.service["master_9443_ingress"]'
terraform state import 'module.emr_instance_fleet.aws_vpc_security_group_ingress_rule.service["master_9443"]' 'sg-xxx'

terraform state rm 'module.emr_instance_fleet.aws_security_group_rule.service["master_9443_egress"]'
terraform state import 'module.emr_instance_fleet.aws_vpc_security_group_egress_rule.service["master_8443"]' 'sg-xxx'

terraform state rm 'module.emr_instance_fleet.aws_security_group_rule.service["core_task_8443_egress"]'
terraform state import 'module.emr_instance_fleet.aws_vpc_security_group_egress_rule.service["core_task_8443"]' 'sg-xxx'
```

#### Serverless sub-module

```sh
terraform state rm 'module.emr_serverless_spark.aws_security_group_rule.this["egress_all"]'
terraform state import 'module.emr_serverless_spark.aws_vpc_security_group_egress_rule.this["all-traffic"]' 'sg-xxx'
```

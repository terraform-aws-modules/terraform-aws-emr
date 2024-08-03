# AWS EMR Studio Terraform module

Terraform module which creates AWS EMR Studio resources.

## Usage

See [`examples`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/examples) directory for working examples to reference:

### IAM Identity Center authentication mode (SSO)

```hcl
module "emr_studio" {
  source = "terraform-aws-modules/emr/aws//modules/studio"

  name                = "example-sso"
  description         = "EMR Studio using SSO authentication"
  auth_mode           = "SSO"
  default_s3_location = "s3://example-s3-bucket/example"

  vpc_id     ="vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  # SSO Mapping
  session_mappings = {
    admin_group = {
      identity_type = "GROUP"
      identity_id   = "012345678f-987a65b4-3210-4567-b5a6-12ab345c6d78"
    }
  }

  tags = local.tags
}
```

### IAM Identity Center authentication mode (SSO)

```hcl
module "emr_studio" {
  source = "terraform-aws-modules/emr/aws//modules/studio"

  name                = "example-iam"
  auth_mode           = "IAM"
  default_s3_location = "s3://example-s3-bucket/example"

  vpc_id     ="vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.59 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.59 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_emr_studio.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_studio) | resource |
| [aws_emr_studio_session_mapping.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_studio_session_mapping) | resource |
| [aws_iam_policy.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.user_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.engine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.engine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.user_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_mode"></a> [auth\_mode](#input\_auth\_mode) | Specifies whether the Studio authenticates users using IAM or Amazon Web Services SSO. Valid values are `SSO` or `IAM` | `string` | `"IAM"` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_security_groups"></a> [create\_security\_groups](#input\_create\_security\_groups) | Determines whether security groups for the EMR Studio engine and workspace are created | `bool` | `true` | no |
| <a name="input_create_service_role"></a> [create\_service\_role](#input\_create\_service\_role) | Determines whether the service IAM role should be created | `bool` | `true` | no |
| <a name="input_create_service_role_policy"></a> [create\_service\_role\_policy](#input\_create\_service\_role\_policy) | Determines whether the service IAM role policy should be created | `bool` | `true` | no |
| <a name="input_create_user_role"></a> [create\_user\_role](#input\_create\_user\_role) | Determines whether the user IAM role should be created | `bool` | `true` | no |
| <a name="input_create_user_role_policy"></a> [create\_user\_role\_policy](#input\_create\_user\_role\_policy) | Determines whether the user IAM role policy should be created | `bool` | `true` | no |
| <a name="input_default_s3_location"></a> [default\_s3\_location](#input\_default\_s3\_location) | The Amazon S3 location to back up Amazon EMR Studio Workspaces and notebook files | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | A detailed description of the Amazon EMR Studio | `string` | `null` | no |
| <a name="input_engine_security_group_description"></a> [engine\_security\_group\_description](#input\_engine\_security\_group\_description) | Description of the security group created | `string` | `"EMR Studio engine security group"` | no |
| <a name="input_engine_security_group_id"></a> [engine\_security\_group\_id](#input\_engine\_security\_group\_id) | The ID of the Amazon EMR Studio Engine security group. The Engine security group allows inbound network traffic from the Workspace security group, and it must be in the same VPC specified by `vpc_id` | `string` | `null` | no |
| <a name="input_engine_security_group_rules"></a> [engine\_security\_group\_rules](#input\_engine\_security\_group\_rules) | Security group rules to add to the security group created | `any` | `{}` | no |
| <a name="input_idp_auth_url"></a> [idp\_auth\_url](#input\_idp\_auth\_url) | The authentication endpoint of your identity provider (IdP). Specify this value when you use IAM authentication and want to let federated users log in to a Studio with the Studio URL and credentials from your IdP | `string` | `null` | no |
| <a name="input_idp_relay_state_parameter_name"></a> [idp\_relay\_state\_parameter\_name](#input\_idp\_relay\_state\_parameter\_name) | The name that your identity provider (IdP) uses for its RelayState parameter. For example, RelayState or TargetSource | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | A descriptive name for the Amazon EMR Studio | `string` | `""` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created. Note - `-engine` and `-workspace` will be appended to this name to distinguish | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | The ARN of an existing IAM role to use for the service | `string` | `null` | no |
| <a name="input_service_role_description"></a> [service\_role\_description](#input\_service\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_service_role_name"></a> [service\_role\_name](#input\_service\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_service_role_path"></a> [service\_role\_path](#input\_service\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_service_role_permissions_boundary"></a> [service\_role\_permissions\_boundary](#input\_service\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_service_role_policies"></a> [service\_role\_policies](#input\_service\_role\_policies) | Map of IAM policies to attach to the service role | `map(string)` | `{}` | no |
| <a name="input_service_role_s3_bucket_arns"></a> [service\_role\_s3\_bucket\_arns](#input\_service\_role\_s3\_bucket\_arns) | A list of Amazon S3 bucket ARNs to allow permission to read/write from the Amazon EMR Studio | `list(string)` | `[]` | no |
| <a name="input_service_role_secrets_manager_arns"></a> [service\_role\_secrets\_manager\_arns](#input\_service\_role\_secrets\_manager\_arns) | A list of Amazon Web Services Secrets Manager secret ARNs to allow use of Git credentials stored in AWS Secrets Manager to link Git repositories to a Workspace | `list(string)` | `[]` | no |
| <a name="input_service_role_statements"></a> [service\_role\_statements](#input\_service\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_service_role_tags"></a> [service\_role\_tags](#input\_service\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_service_role_use_name_prefix"></a> [service\_role\_use\_name\_prefix](#input\_service\_role\_use\_name\_prefix) | Determines whether the IAM role name is used as a prefix | `bool` | `true` | no |
| <a name="input_session_mappings"></a> [session\_mappings](#input\_session\_mappings) | A map of session mapping definitions to apply to the Studio | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to associate with the Amazon EMR Studio. A Studio can have a maximum of 5 subnets. The subnets must belong to the VPC specified by `vpc_id` | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_user_role_arn"></a> [user\_role\_arn](#input\_user\_role\_arn) | The ARN of an existing IAM role to use for the user | `string` | `null` | no |
| <a name="input_user_role_description"></a> [user\_role\_description](#input\_user\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_user_role_name"></a> [user\_role\_name](#input\_user\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_user_role_path"></a> [user\_role\_path](#input\_user\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_user_role_permissions_boundary"></a> [user\_role\_permissions\_boundary](#input\_user\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_user_role_policies"></a> [user\_role\_policies](#input\_user\_role\_policies) | Map of IAM policies to attach to the user role | `map(string)` | `{}` | no |
| <a name="input_user_role_s3_bucket_arns"></a> [user\_role\_s3\_bucket\_arns](#input\_user\_role\_s3\_bucket\_arns) | A list of Amazon S3 bucket ARNs to allow permission to read/write from the Amazon EMR Studio user role | `list(string)` | `[]` | no |
| <a name="input_user_role_statements"></a> [user\_role\_statements](#input\_user\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_user_role_tags"></a> [user\_role\_tags](#input\_user\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_user_role_use_name_prefix"></a> [user\_role\_use\_name\_prefix](#input\_user\_role\_use\_name\_prefix) | Determines whether the IAM role name is used as a prefix | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the Amazon Virtual Private Cloud (Amazon VPC) to associate with the Studio | `string` | `""` | no |
| <a name="input_workspace_security_group_description"></a> [workspace\_security\_group\_description](#input\_workspace\_security\_group\_description) | Description of the security group created | `string` | `"EMR Studio workspace security group"` | no |
| <a name="input_workspace_security_group_id"></a> [workspace\_security\_group\_id](#input\_workspace\_security\_group\_id) | The ID of the Amazon EMR Studio Workspace security group. The Workspace security group allows outbound network traffic to resources in the Engine security group, and it must be in the same VPC specified by `vpc_id` | `string` | `null` | no |
| <a name="input_workspace_security_group_rules"></a> [workspace\_security\_group\_rules](#input\_workspace\_security\_group\_rules) | Security group rules to add to the security group created. Note - only egress rules are permitted | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the studio |
| <a name="output_engine_security_group_arn"></a> [engine\_security\_group\_arn](#output\_engine\_security\_group\_arn) | Amazon Resource Name (ARN) of the engine security group |
| <a name="output_engine_security_group_id"></a> [engine\_security\_group\_id](#output\_engine\_security\_group\_id) | ID of the engine security group |
| <a name="output_service_iam_role_arn"></a> [service\_iam\_role\_arn](#output\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_service_iam_role_name"></a> [service\_iam\_role\_name](#output\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_service_iam_role_policy_arn"></a> [service\_iam\_role\_policy\_arn](#output\_service\_iam\_role\_policy\_arn) | Service IAM role policy ARN |
| <a name="output_service_iam_role_policy_id"></a> [service\_iam\_role\_policy\_id](#output\_service\_iam\_role\_policy\_id) | Service IAM role policy ID |
| <a name="output_service_iam_role_policy_name"></a> [service\_iam\_role\_policy\_name](#output\_service\_iam\_role\_policy\_name) | The name of the service role policy |
| <a name="output_service_iam_role_unique_id"></a> [service\_iam\_role\_unique\_id](#output\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_url"></a> [url](#output\_url) | The unique access URL of the Amazon EMR Studio |
| <a name="output_user_iam_role_arn"></a> [user\_iam\_role\_arn](#output\_user\_iam\_role\_arn) | User IAM role ARN |
| <a name="output_user_iam_role_name"></a> [user\_iam\_role\_name](#output\_user\_iam\_role\_name) | User IAM role name |
| <a name="output_user_iam_role_policy_arn"></a> [user\_iam\_role\_policy\_arn](#output\_user\_iam\_role\_policy\_arn) | User IAM role policy ARN |
| <a name="output_user_iam_role_policy_id"></a> [user\_iam\_role\_policy\_id](#output\_user\_iam\_role\_policy\_id) | User IAM role policy ID |
| <a name="output_user_iam_role_policy_name"></a> [user\_iam\_role\_policy\_name](#output\_user\_iam\_role\_policy\_name) | The name of the user role policy |
| <a name="output_user_iam_role_unique_id"></a> [user\_iam\_role\_unique\_id](#output\_user\_iam\_role\_unique\_id) | Stable and unique string identifying the user IAM role |
| <a name="output_workspace_security_group_arn"></a> [workspace\_security\_group\_arn](#output\_workspace\_security\_group\_arn) | Amazon Resource Name (ARN) of the workspace security group |
| <a name="output_workspace_security_group_id"></a> [workspace\_security\_group\_id](#output\_workspace\_security\_group\_id) | ID of the workspace security group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

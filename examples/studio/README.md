# AWS EMR Studio Example

Configuration in this directory creates:

- EMR Studio demonstrating majority of configurations available
- EMR Studio that utilizes IAM Identity Center (SSO) authentication mode
- EMR Studio that utilizes IAM authentication mode

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.42 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.42 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_emr_studio_complete"></a> [emr\_studio\_complete](#module\_emr\_studio\_complete) | ../../modules/studio | n/a |
| <a name="module_emr_studio_disabled"></a> [emr\_studio\_disabled](#module\_emr\_studio\_disabled) | ../../modules/studio | n/a |
| <a name="module_emr_studio_iam"></a> [emr\_studio\_iam](#module\_emr\_studio\_iam) | ../../modules/studio | n/a |
| <a name="module_emr_studio_sso"></a> [emr\_studio\_sso](#module\_emr\_studio\_sso) | ../../modules/studio | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> v3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_complete_arn"></a> [complete\_arn](#output\_complete\_arn) | ARN of the studio |
| <a name="output_complete_engine_security_group_arn"></a> [complete\_engine\_security\_group\_arn](#output\_complete\_engine\_security\_group\_arn) | Amazon Resource Name (ARN) of the engine security group |
| <a name="output_complete_engine_security_group_id"></a> [complete\_engine\_security\_group\_id](#output\_complete\_engine\_security\_group\_id) | ID of the engine security group |
| <a name="output_complete_service_iam_role_arn"></a> [complete\_service\_iam\_role\_arn](#output\_complete\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_complete_service_iam_role_name"></a> [complete\_service\_iam\_role\_name](#output\_complete\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_complete_service_iam_role_policy_arn"></a> [complete\_service\_iam\_role\_policy\_arn](#output\_complete\_service\_iam\_role\_policy\_arn) | Service IAM role policy ARN |
| <a name="output_complete_service_iam_role_policy_id"></a> [complete\_service\_iam\_role\_policy\_id](#output\_complete\_service\_iam\_role\_policy\_id) | Service IAM role policy ID |
| <a name="output_complete_service_iam_role_policy_name"></a> [complete\_service\_iam\_role\_policy\_name](#output\_complete\_service\_iam\_role\_policy\_name) | The name of the service role policy |
| <a name="output_complete_service_iam_role_unique_id"></a> [complete\_service\_iam\_role\_unique\_id](#output\_complete\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_complete_url"></a> [complete\_url](#output\_complete\_url) | The unique access URL of the Amazon EMR Studio |
| <a name="output_complete_user_iam_role_arn"></a> [complete\_user\_iam\_role\_arn](#output\_complete\_user\_iam\_role\_arn) | User IAM role ARN |
| <a name="output_complete_user_iam_role_name"></a> [complete\_user\_iam\_role\_name](#output\_complete\_user\_iam\_role\_name) | User IAM role name |
| <a name="output_complete_user_iam_role_policy_arn"></a> [complete\_user\_iam\_role\_policy\_arn](#output\_complete\_user\_iam\_role\_policy\_arn) | User IAM role policy ARN |
| <a name="output_complete_user_iam_role_policy_id"></a> [complete\_user\_iam\_role\_policy\_id](#output\_complete\_user\_iam\_role\_policy\_id) | User IAM role policy ID |
| <a name="output_complete_user_iam_role_policy_name"></a> [complete\_user\_iam\_role\_policy\_name](#output\_complete\_user\_iam\_role\_policy\_name) | The name of the user role policy |
| <a name="output_complete_user_iam_role_unique_id"></a> [complete\_user\_iam\_role\_unique\_id](#output\_complete\_user\_iam\_role\_unique\_id) | Stable and unique string identifying the user IAM role |
| <a name="output_complete_workspace_security_group_arn"></a> [complete\_workspace\_security\_group\_arn](#output\_complete\_workspace\_security\_group\_arn) | Amazon Resource Name (ARN) of the workspace security group |
| <a name="output_complete_workspace_security_group_id"></a> [complete\_workspace\_security\_group\_id](#output\_complete\_workspace\_security\_group\_id) | ID of the workspace security group |
| <a name="output_iam_arn"></a> [iam\_arn](#output\_iam\_arn) | ARN of the studio |
| <a name="output_iam_engine_security_group_arn"></a> [iam\_engine\_security\_group\_arn](#output\_iam\_engine\_security\_group\_arn) | Amazon Resource Name (ARN) of the engine security group |
| <a name="output_iam_engine_security_group_id"></a> [iam\_engine\_security\_group\_id](#output\_iam\_engine\_security\_group\_id) | ID of the engine security group |
| <a name="output_iam_service_iam_role_arn"></a> [iam\_service\_iam\_role\_arn](#output\_iam\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_iam_service_iam_role_name"></a> [iam\_service\_iam\_role\_name](#output\_iam\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_iam_service_iam_role_policy_arn"></a> [iam\_service\_iam\_role\_policy\_arn](#output\_iam\_service\_iam\_role\_policy\_arn) | Service IAM role policy ARN |
| <a name="output_iam_service_iam_role_policy_id"></a> [iam\_service\_iam\_role\_policy\_id](#output\_iam\_service\_iam\_role\_policy\_id) | Service IAM role policy ID |
| <a name="output_iam_service_iam_role_policy_name"></a> [iam\_service\_iam\_role\_policy\_name](#output\_iam\_service\_iam\_role\_policy\_name) | The name of the service role policy |
| <a name="output_iam_service_iam_role_unique_id"></a> [iam\_service\_iam\_role\_unique\_id](#output\_iam\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_iam_url"></a> [iam\_url](#output\_iam\_url) | The unique access URL of the Amazon EMR Studio |
| <a name="output_iam_user_iam_role_arn"></a> [iam\_user\_iam\_role\_arn](#output\_iam\_user\_iam\_role\_arn) | User IAM role ARN |
| <a name="output_iam_user_iam_role_name"></a> [iam\_user\_iam\_role\_name](#output\_iam\_user\_iam\_role\_name) | User IAM role name |
| <a name="output_iam_user_iam_role_policy_arn"></a> [iam\_user\_iam\_role\_policy\_arn](#output\_iam\_user\_iam\_role\_policy\_arn) | User IAM role policy ARN |
| <a name="output_iam_user_iam_role_policy_id"></a> [iam\_user\_iam\_role\_policy\_id](#output\_iam\_user\_iam\_role\_policy\_id) | User IAM role policy ID |
| <a name="output_iam_user_iam_role_policy_name"></a> [iam\_user\_iam\_role\_policy\_name](#output\_iam\_user\_iam\_role\_policy\_name) | The name of the user role policy |
| <a name="output_iam_user_iam_role_unique_id"></a> [iam\_user\_iam\_role\_unique\_id](#output\_iam\_user\_iam\_role\_unique\_id) | Stable and unique string identifying the user IAM role |
| <a name="output_iam_workspace_security_group_arn"></a> [iam\_workspace\_security\_group\_arn](#output\_iam\_workspace\_security\_group\_arn) | Amazon Resource Name (ARN) of the workspace security group |
| <a name="output_iam_workspace_security_group_id"></a> [iam\_workspace\_security\_group\_id](#output\_iam\_workspace\_security\_group\_id) | ID of the workspace security group |
| <a name="output_sso_arn"></a> [sso\_arn](#output\_sso\_arn) | ARN of the studio |
| <a name="output_sso_engine_security_group_arn"></a> [sso\_engine\_security\_group\_arn](#output\_sso\_engine\_security\_group\_arn) | Amazon Resource Name (ARN) of the engine security group |
| <a name="output_sso_engine_security_group_id"></a> [sso\_engine\_security\_group\_id](#output\_sso\_engine\_security\_group\_id) | ID of the engine security group |
| <a name="output_sso_service_iam_role_arn"></a> [sso\_service\_iam\_role\_arn](#output\_sso\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_sso_service_iam_role_name"></a> [sso\_service\_iam\_role\_name](#output\_sso\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_sso_service_iam_role_policy_arn"></a> [sso\_service\_iam\_role\_policy\_arn](#output\_sso\_service\_iam\_role\_policy\_arn) | Service IAM role policy ARN |
| <a name="output_sso_service_iam_role_policy_id"></a> [sso\_service\_iam\_role\_policy\_id](#output\_sso\_service\_iam\_role\_policy\_id) | Service IAM role policy ID |
| <a name="output_sso_service_iam_role_policy_name"></a> [sso\_service\_iam\_role\_policy\_name](#output\_sso\_service\_iam\_role\_policy\_name) | The name of the service role policy |
| <a name="output_sso_service_iam_role_unique_id"></a> [sso\_service\_iam\_role\_unique\_id](#output\_sso\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_sso_url"></a> [sso\_url](#output\_sso\_url) | The unique access URL of the Amazon EMR Studio |
| <a name="output_sso_user_iam_role_arn"></a> [sso\_user\_iam\_role\_arn](#output\_sso\_user\_iam\_role\_arn) | User IAM role ARN |
| <a name="output_sso_user_iam_role_name"></a> [sso\_user\_iam\_role\_name](#output\_sso\_user\_iam\_role\_name) | User IAM role name |
| <a name="output_sso_user_iam_role_policy_arn"></a> [sso\_user\_iam\_role\_policy\_arn](#output\_sso\_user\_iam\_role\_policy\_arn) | User IAM role policy ARN |
| <a name="output_sso_user_iam_role_policy_id"></a> [sso\_user\_iam\_role\_policy\_id](#output\_sso\_user\_iam\_role\_policy\_id) | User IAM role policy ID |
| <a name="output_sso_user_iam_role_policy_name"></a> [sso\_user\_iam\_role\_policy\_name](#output\_sso\_user\_iam\_role\_policy\_name) | The name of the user role policy |
| <a name="output_sso_user_iam_role_unique_id"></a> [sso\_user\_iam\_role\_unique\_id](#output\_sso\_user\_iam\_role\_unique\_id) | Stable and unique string identifying the user IAM role |
| <a name="output_sso_workspace_security_group_arn"></a> [sso\_workspace\_security\_group\_arn](#output\_sso\_workspace\_security\_group\_arn) | Amazon Resource Name (ARN) of the workspace security group |
| <a name="output_sso_workspace_security_group_id"></a> [sso\_workspace\_security\_group\_id](#output\_sso\_workspace\_security\_group\_id) | ID of the workspace security group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

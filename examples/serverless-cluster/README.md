# AWS EMR Serverless Cluster Example

Configuration in this directory creates:

- EMR serverless cluster running Spark provisioned in private subnets with a custom security group
- EMR serverless cluster running Hive
- Disabled EMR serverless cluster

Note: The public subnets will need to be tagged with `{ "for-use-with-amazon-emr-managed-policies" = true }` ([Reference](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources))

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.83 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.83 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_emr_serverless_disabled"></a> [emr\_serverless\_disabled](#module\_emr\_serverless\_disabled) | ../../modules/serverless | n/a |
| <a name="module_emr_serverless_hive"></a> [emr\_serverless\_hive](#module\_emr\_serverless\_hive) | ../../modules/serverless | n/a |
| <a name="module_emr_serverless_spark"></a> [emr\_serverless\_spark](#module\_emr\_serverless\_spark) | ../../modules/serverless | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disabled_arn"></a> [disabled\_arn](#output\_disabled\_arn) | Amazon Resource Name (ARN) of the application |
| <a name="output_disabled_id"></a> [disabled\_id](#output\_disabled\_id) | ID of the application |
| <a name="output_disabled_security_group_arn"></a> [disabled\_security\_group\_arn](#output\_disabled\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_disabled_security_group_id"></a> [disabled\_security\_group\_id](#output\_disabled\_security\_group\_id) | ID of the security group |
| <a name="output_hive_arn"></a> [hive\_arn](#output\_hive\_arn) | Amazon Resource Name (ARN) of the application |
| <a name="output_hive_id"></a> [hive\_id](#output\_hive\_id) | ID of the application |
| <a name="output_hive_security_group_arn"></a> [hive\_security\_group\_arn](#output\_hive\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_hive_security_group_id"></a> [hive\_security\_group\_id](#output\_hive\_security\_group\_id) | ID of the security group |
| <a name="output_spark_arn"></a> [spark\_arn](#output\_spark\_arn) | Amazon Resource Name (ARN) of the application |
| <a name="output_spark_id"></a> [spark\_id](#output\_spark\_id) | ID of the application |
| <a name="output_spark_security_group_arn"></a> [spark\_security\_group\_arn](#output\_spark\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_spark_security_group_id"></a> [spark\_security\_group\_id](#output\_spark\_security\_group\_id) | ID of the security group |
<!-- END_TF_DOCS -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

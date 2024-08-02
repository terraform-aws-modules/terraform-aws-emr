# AWS EMR Public Cluster Example

Configuration in this directory creates:

- EMR cluster using instance fleets (`master`, `core`, `task`) deployed into public subnets
- EMR cluster using instance groups (`master`, `core`, `task`) deployed into public subnets
- S3 bucket for EMR logs

Note: The public subnets will need to be tagged with `{ "for-use-with-amazon-emr-managed-policies" = true }` ([Reference](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources))

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_emr_instance_fleet"></a> [emr\_instance\_fleet](#module\_emr\_instance\_fleet) | ../.. | n/a |
| <a name="module_emr_instance_group"></a> [emr\_instance\_group](#module\_emr\_instance\_group) | ../.. | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
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
| <a name="output_fleet_autoscaling_iam_role_arn"></a> [fleet\_autoscaling\_iam\_role\_arn](#output\_fleet\_autoscaling\_iam\_role\_arn) | Autoscaling IAM role ARN |
| <a name="output_fleet_autoscaling_iam_role_name"></a> [fleet\_autoscaling\_iam\_role\_name](#output\_fleet\_autoscaling\_iam\_role\_name) | Autoscaling IAM role name |
| <a name="output_fleet_autoscaling_iam_role_unique_id"></a> [fleet\_autoscaling\_iam\_role\_unique\_id](#output\_fleet\_autoscaling\_iam\_role\_unique\_id) | Stable and unique string identifying the autoscaling IAM role |
| <a name="output_fleet_cluster_arn"></a> [fleet\_cluster\_arn](#output\_fleet\_cluster\_arn) | The ARN of the cluster |
| <a name="output_fleet_cluster_core_instance_group_id"></a> [fleet\_cluster\_core\_instance\_group\_id](#output\_fleet\_cluster\_core\_instance\_group\_id) | Core node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_fleet_cluster_id"></a> [fleet\_cluster\_id](#output\_fleet\_cluster\_id) | The ID of the cluster |
| <a name="output_fleet_cluster_master_instance_group_id"></a> [fleet\_cluster\_master\_instance\_group\_id](#output\_fleet\_cluster\_master\_instance\_group\_id) | Master node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_fleet_cluster_master_public_dns"></a> [fleet\_cluster\_master\_public\_dns](#output\_fleet\_cluster\_master\_public\_dns) | The DNS name of the master node. If the cluster is on a private subnet, this is the private DNS name. On a public subnet, this is the public DNS name |
| <a name="output_fleet_iam_instance_profile_arn"></a> [fleet\_iam\_instance\_profile\_arn](#output\_fleet\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_fleet_iam_instance_profile_iam_role_arn"></a> [fleet\_iam\_instance\_profile\_iam\_role\_arn](#output\_fleet\_iam\_instance\_profile\_iam\_role\_arn) | Instance profile IAM role ARN |
| <a name="output_fleet_iam_instance_profile_iam_role_name"></a> [fleet\_iam\_instance\_profile\_iam\_role\_name](#output\_fleet\_iam\_instance\_profile\_iam\_role\_name) | Instance profile IAM role name |
| <a name="output_fleet_iam_instance_profile_iam_role_unique_id"></a> [fleet\_iam\_instance\_profile\_iam\_role\_unique\_id](#output\_fleet\_iam\_instance\_profile\_iam\_role\_unique\_id) | Stable and unique string identifying the instance profile IAM role |
| <a name="output_fleet_iam_instance_profile_id"></a> [fleet\_iam\_instance\_profile\_id](#output\_fleet\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_fleet_iam_instance_profile_unique"></a> [fleet\_iam\_instance\_profile\_unique](#output\_fleet\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_fleet_managed_master_security_group_arn"></a> [fleet\_managed\_master\_security\_group\_arn](#output\_fleet\_managed\_master\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed master security group |
| <a name="output_fleet_managed_master_security_group_id"></a> [fleet\_managed\_master\_security\_group\_id](#output\_fleet\_managed\_master\_security\_group\_id) | ID of the managed master security group |
| <a name="output_fleet_managed_service_access_security_group_arn"></a> [fleet\_managed\_service\_access\_security\_group\_arn](#output\_fleet\_managed\_service\_access\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed service access security group |
| <a name="output_fleet_managed_service_access_security_group_id"></a> [fleet\_managed\_service\_access\_security\_group\_id](#output\_fleet\_managed\_service\_access\_security\_group\_id) | ID of the managed service access security group |
| <a name="output_fleet_managed_slave_security_group_arn"></a> [fleet\_managed\_slave\_security\_group\_arn](#output\_fleet\_managed\_slave\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed slave security group |
| <a name="output_fleet_managed_slave_security_group_id"></a> [fleet\_managed\_slave\_security\_group\_id](#output\_fleet\_managed\_slave\_security\_group\_id) | ID of the managed slave security group |
| <a name="output_fleet_security_configuration_id"></a> [fleet\_security\_configuration\_id](#output\_fleet\_security\_configuration\_id) | The ID of the security configuration |
| <a name="output_fleet_security_configuration_name"></a> [fleet\_security\_configuration\_name](#output\_fleet\_security\_configuration\_name) | The name of the security configuration |
| <a name="output_fleet_service_iam_role_arn"></a> [fleet\_service\_iam\_role\_arn](#output\_fleet\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_fleet_service_iam_role_name"></a> [fleet\_service\_iam\_role\_name](#output\_fleet\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_fleet_service_iam_role_unique_id"></a> [fleet\_service\_iam\_role\_unique\_id](#output\_fleet\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_group_autoscaling_iam_role_arn"></a> [group\_autoscaling\_iam\_role\_arn](#output\_group\_autoscaling\_iam\_role\_arn) | Autoscaling IAM role ARN |
| <a name="output_group_autoscaling_iam_role_name"></a> [group\_autoscaling\_iam\_role\_name](#output\_group\_autoscaling\_iam\_role\_name) | Autoscaling IAM role name |
| <a name="output_group_autoscaling_iam_role_unique_id"></a> [group\_autoscaling\_iam\_role\_unique\_id](#output\_group\_autoscaling\_iam\_role\_unique\_id) | Stable and unique string identifying the autoscaling IAM role |
| <a name="output_group_cluster_arn"></a> [group\_cluster\_arn](#output\_group\_cluster\_arn) | The ARN of the cluster |
| <a name="output_group_cluster_core_instance_group_id"></a> [group\_cluster\_core\_instance\_group\_id](#output\_group\_cluster\_core\_instance\_group\_id) | Core node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_group_cluster_id"></a> [group\_cluster\_id](#output\_group\_cluster\_id) | The ID of the cluster |
| <a name="output_group_cluster_master_instance_group_id"></a> [group\_cluster\_master\_instance\_group\_id](#output\_group\_cluster\_master\_instance\_group\_id) | Master node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_group_cluster_master_public_dns"></a> [group\_cluster\_master\_public\_dns](#output\_group\_cluster\_master\_public\_dns) | The DNS name of the master node. If the cluster is on a private subnet, this is the private DNS name. On a public subnet, this is the public DNS name |
| <a name="output_group_iam_instance_profile_arn"></a> [group\_iam\_instance\_profile\_arn](#output\_group\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_group_iam_instance_profile_iam_role_arn"></a> [group\_iam\_instance\_profile\_iam\_role\_arn](#output\_group\_iam\_instance\_profile\_iam\_role\_arn) | Instance profile IAM role ARN |
| <a name="output_group_iam_instance_profile_iam_role_name"></a> [group\_iam\_instance\_profile\_iam\_role\_name](#output\_group\_iam\_instance\_profile\_iam\_role\_name) | Instance profile IAM role name |
| <a name="output_group_iam_instance_profile_iam_role_unique_id"></a> [group\_iam\_instance\_profile\_iam\_role\_unique\_id](#output\_group\_iam\_instance\_profile\_iam\_role\_unique\_id) | Stable and unique string identifying the instance profile IAM role |
| <a name="output_group_iam_instance_profile_id"></a> [group\_iam\_instance\_profile\_id](#output\_group\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_group_iam_instance_profile_unique"></a> [group\_iam\_instance\_profile\_unique](#output\_group\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_group_managed_master_security_group_arn"></a> [group\_managed\_master\_security\_group\_arn](#output\_group\_managed\_master\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed master security group |
| <a name="output_group_managed_master_security_group_id"></a> [group\_managed\_master\_security\_group\_id](#output\_group\_managed\_master\_security\_group\_id) | ID of the managed master security group |
| <a name="output_group_managed_service_access_security_group_arn"></a> [group\_managed\_service\_access\_security\_group\_arn](#output\_group\_managed\_service\_access\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed service access security group |
| <a name="output_group_managed_service_access_security_group_id"></a> [group\_managed\_service\_access\_security\_group\_id](#output\_group\_managed\_service\_access\_security\_group\_id) | ID of the managed service access security group |
| <a name="output_group_managed_slave_security_group_arn"></a> [group\_managed\_slave\_security\_group\_arn](#output\_group\_managed\_slave\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed slave security group |
| <a name="output_group_managed_slave_security_group_id"></a> [group\_managed\_slave\_security\_group\_id](#output\_group\_managed\_slave\_security\_group\_id) | ID of the managed slave security group |
| <a name="output_group_security_configuration_id"></a> [group\_security\_configuration\_id](#output\_group\_security\_configuration\_id) | The ID of the security configuration |
| <a name="output_group_security_configuration_name"></a> [group\_security\_configuration\_name](#output\_group\_security\_configuration\_name) | The name of the security configuration |
| <a name="output_group_service_iam_role_arn"></a> [group\_service\_iam\_role\_arn](#output\_group\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_group_service_iam_role_name"></a> [group\_service\_iam\_role\_name](#output\_group\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_group_service_iam_role_unique_id"></a> [group\_service\_iam\_role\_unique\_id](#output\_group\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

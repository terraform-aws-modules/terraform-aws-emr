# AWS EMR Virtual Cluster Example

This example shows how to provision a serverless cluster (serverless data plane) using Fargate Profiles to support EMR on EKS virtual clusters.

There are two Fargate profiles created:
1. `kube-system` to support core Kubernetes components such as CoreDNS
2. `emr-wildcard` which supports any namespaces that begin with `emr-*`; this allows for creating multiple virtual clusters without having to create additional Fargate profiles for each new cluster.

The resources created by the `virtual-cluster` module include:
- Kubernetes namespace, role, and role binding; existing or externally created namespace and role can be utilized as well
- IAM role for service account (IRSA) used by for job execution. Users can scope access to the appropriate S3 bucket and path via `s3_bucket_arns`, use for both accessing job data as well as writing out results. The bare minimum permissions have been provided for the job execution role; users can provide additional permissions by passing in additional policies to attach to the role via `iam_role_additional_policies`
- CloudWatch log group for task execution logs. Log streams are created by the job itself and not via Terraform
- EMR managed security group for the virtual cluster
- EMR virtual cluster scoped to the namespace created/provided

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

## Destroy

If the EMR virtual cluster fails to delete and the following error is shown:

> Error: waiting for EMR Containers Virtual Cluster (xwbc22787q6g1wscfawttzzgb) delete: unexpected state 'ARRESTED', wanted target ''. last error: %!s(<nil>)

You can clean up any of the clusters in the `ARRESTED` state with the following:

```sh
aws emr-containers list-virtual-clusters --region us-west-2 --states ARRESTED \
--query 'virtualClusters[0].id' --output text | xargs -I{} aws emr-containers delete-virtual-cluster \
--region us-west-2 --id {}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.59 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.17 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.59 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_complete"></a> [complete](#module\_complete) | ../../modules/virtual-cluster | n/a |
| <a name="module_default"></a> [default](#module\_default) | ../../modules/virtual-cluster | n/a |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../modules/virtual-cluster | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.13 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.0 |
| <a name="module_vpc_endpoints_sg"></a> [vpc\_endpoints\_sg](#module\_vpc\_endpoints\_sg) | terraform-aws-modules/security-group/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [null_resource.s3_sync](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.start_job_run](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.coredns](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_complete_cloudwatch_log_group_arn"></a> [complete\_cloudwatch\_log\_group\_arn](#output\_complete\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_complete_cloudwatch_log_group_name"></a> [complete\_cloudwatch\_log\_group\_name](#output\_complete\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_complete_job_execution_role_arn"></a> [complete\_job\_execution\_role\_arn](#output\_complete\_job\_execution\_role\_arn) | IAM role ARN of the job execution role |
| <a name="output_complete_job_execution_role_name"></a> [complete\_job\_execution\_role\_name](#output\_complete\_job\_execution\_role\_name) | IAM role name of the job execution role |
| <a name="output_complete_job_execution_role_unique_id"></a> [complete\_job\_execution\_role\_unique\_id](#output\_complete\_job\_execution\_role\_unique\_id) | Stable and unique string identifying the job execution IAM role |
| <a name="output_complete_virtual_cluster_arn"></a> [complete\_virtual\_cluster\_arn](#output\_complete\_virtual\_cluster\_arn) | ARN of the EMR virtual cluster |
| <a name="output_complete_virtual_cluster_id"></a> [complete\_virtual\_cluster\_id](#output\_complete\_virtual\_cluster\_id) | ID of the EMR virtual cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/LICENSE).

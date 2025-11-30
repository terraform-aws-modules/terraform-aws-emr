# Changelog

All notable changes to this project will be documented in this file.

## [3.1.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v3.0.1...v3.1.0) (2025-11-30)

### Features

* Support `scaling_strategy` and `utilization_performance_index` for EMR managed scaling policy ([#48](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/48)) ([61da1c0](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/61da1c09022927371f1576ddc4062479c5689077))

## [3.0.1](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v3.0.0...v3.0.1) (2025-11-18)

### Bug Fixes

* EMR Serverless `runtime_configuration` should support multiple configurtions  ([#47](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/47)) ([9e11092](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/9e11092cd496e74fb78d948085641eaf9dbb3319))

## [3.0.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.4.3...v3.0.0) (2025-11-14)

### ⚠ BREAKING CHANGES

* Upgrade AWS provider and min required Terraform version to `6.19` and `1.5.7` respectively (#45)

### Features

* Upgrade AWS provider and min required Terraform version to `6.19` and `1.5.7` respectively ([#45](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/45)) ([a674683](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/a674683e6f46bb21a1d503198eb2f6897912e7a1))

## [2.4.3](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.4.2...v2.4.3) (2025-10-21)

### Bug Fixes

* Update CI workflow versions to latest ([#43](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/43)) ([8fca629](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/8fca629fe1e817a7ec9d5f41e01ca23f2357f4f9))

## [2.4.2](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.4.1...v2.4.2) (2025-05-30)


### Bug Fixes

* Align EMR EKS Job Execution role with AWS docs ([#38](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/38)) ([0c7fec0](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/0c7fec0f78534e20c64fb14120d49af8efc335bb))

## [2.4.1](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.4.0...v2.4.1) (2025-03-30)


### Bug Fixes

* Add dependency on service security group rules ([#37](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/37)) ([150d89c](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/150d89c2b471376190e59adac10b99b0cdfa212d))

## [2.4.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.3.0...v2.4.0) (2025-01-15)


### Features

* Support studio `encryption_key_arn` ([#35](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/35)) ([8122444](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/81224444712633533d40dc951e888357a46ffe57))


### Bug Fixes

* Update CI workflow versions to latest ([#31](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/31)) ([ad34d3d](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/ad34d3d55581d51dff978d936d8ebc261f39e646))

## [2.3.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.2.0...v2.3.0) (2024-09-21)


### Features

* Allow passing in custom instance profile role ([#30](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/30)) ([0712293](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/0712293bce835f099d5bc43e45320bc23eb5eacd))

## [2.2.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.1.0...v2.2.0) (2024-08-03)


### Features

* Support interactive configuration block for EMR serverless application ([#27](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/27)) ([2e7045e](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/2e7045e99ee36bb93be4036388f01bbf4fcdbcdd))

## [2.1.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v2.0.0...v2.1.0) (2024-05-04)


### Features

* Reset default value of s3_bucket_arns to empty ([#23](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/23)) ([d8d79df](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/d8d79df4dfe1c590c369ebb939a9e262de6cd42a))

## [2.0.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.2.2...v2.0.0) (2024-04-07)


### ⚠ BREAKING CHANGES

* Add support for placement group config and unhealthy node replacement; raise AWS provider MSV to v5.44 (#21)

### Features

* Add support for placement group config and unhealthy node replacement; raise AWS provider MSV to v5.44 ([#21](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/21)) ([eff2018](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/eff2018e7aeffdd260c21b9251275fa8342c34de))

## [1.2.2](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.2.1...v1.2.2) (2024-03-07)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#18](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/18)) ([faf4d0b](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/faf4d0bfc218bc70d2124bed5e52780bb0856c2d))

### [1.2.1](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.2.0...v1.2.1) (2024-02-08)


### Bug Fixes

* Add `"deletecollection"` verb to `"persistentvolumeclaims"` Kubernetes RBAC permission ([#17](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/17)) ([668f09b](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/668f09bcb2eb3dbac1be59648f00a4a7acbf832f))

## [1.2.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.1.3...v1.2.0) (2023-07-21)


### Features

* Allowing Custom CloudWatch Log Group Name or Prefix ([#13](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/13)) ([1be0b5e](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/1be0b5e325f6ac458773c7eddc469397b57795a5))

### [1.1.3](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.1.2...v1.1.3) (2023-07-18)


### Bug Fixes

* Updating Kubernetes Role for EMR Virtual Cluster ([#12](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/12)) ([05bc754](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/05bc754beddd0156271f05ccfd8702b9a6ba07b2))

### [1.1.2](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.1.1...v1.1.2) (2023-06-12)


### Bug Fixes

* Remove wrapping list brackets from S3 bucket ARNs variable ([#9](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/9)) ([2317c56](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/2317c56f9b6715224af6eba4e7fe54ec0f0d4217))

### [1.1.1](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.1.0...v1.1.1) (2023-06-10)


### Bug Fixes

* Correct S3 bucket access permission to try user provided S3 bucket ARNs first before falling back to default ([#8](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/8)) ([ae366ed](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/ae366ed81939a06a00c843edbf01097edee2353a))

## [1.1.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.0.0...v1.1.0) (2023-05-18)


### Features

* Add support for image_configuration block in serverless module ([#2](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/2)) ([4d29ee5](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/4d29ee518322bffe48a3bc6fb096b3fe929b4eb0))


### Bug Fixes

* Correct auto-release configuration file ([#6](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/6)) ([74847b1](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/74847b1dce3058d43e0a50affcf03fefee06a236))
* Update EMR studio service role policy to RequestTags on Create* ([#5](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/5)) ([274efc3](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/274efc33cb7b251778019a66e9eed62b58722c8b))

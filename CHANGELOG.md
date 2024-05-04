# Changelog

All notable changes to this project will be documented in this file.

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

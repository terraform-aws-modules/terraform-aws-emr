# Changelog

All notable changes to this project will be documented in this file.

### [1.1.1](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.1.0...v1.1.1) (2023-06-10)


### Bug Fixes

* Correct S3 bucket access permission to try user provided S3 bucket ARNs first before falling back to default ([#8](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/8)) ([ae366ed](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/ae366ed81939a06a00c843edbf01097edee2353a))

## [1.1.0](https://github.com/terraform-aws-modules/terraform-aws-emr/compare/v1.0.0...v1.1.0) (2023-05-18)


### Features

* Add support for image_configuration block in serverless module ([#2](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/2)) ([4d29ee5](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/4d29ee518322bffe48a3bc6fb096b3fe929b4eb0))


### Bug Fixes

* Correct auto-release configuration file ([#6](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/6)) ([74847b1](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/74847b1dce3058d43e0a50affcf03fefee06a236))
* Update EMR studio service role policy to RequestTags on Create* ([#5](https://github.com/terraform-aws-modules/terraform-aws-emr/issues/5)) ([274efc3](https://github.com/terraform-aws-modules/terraform-aws-emr/commit/274efc33cb7b251778019a66e9eed62b58722c8b))

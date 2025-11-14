################################################################################
# Migrations: v2.4.3 -> v3.0
################################################################################

moved {
  from = aws_emr_instance_group.this["0"]
  to   = aws_emr_instance_group.this[0]
}

moved {
  from = aws_emr_instance_fleet.this["0"]
  to   = aws_emr_instance_fleet.this[0]
}


# module.emr_instance_fleet.aws_iam_role_policy_attachment.autoscaling[0] will be created
# module.emr_instance_fleet.aws_iam_role.autoscaling[0] will be created

# module.emr_instance_group.aws_iam_role_policy_attachment.autoscaling[0] will be destroyed
# module.emr_instance_group.aws_iam_role.autoscaling[0] will be destroyed

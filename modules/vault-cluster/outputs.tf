output "asg_name" {
  value = aws_autoscaling_group.autoscaling_group.name
}

output "cluster_tag_key" {
  value = var.cluster_tag_key
}

output "cluster_tag_value" {
  value = var.cluster_name
}

output "cluster_size" {
  value = aws_autoscaling_group.autoscaling_group.desired_capacity
}

output "launch_config_name" {
  value = aws_launch_configuration.launch_configuration.name
}

output "iam_role_arn" {
  value = aws_iam_role.instance_role.arn
}

output "iam_role_id" {
  value = aws_iam_role.instance_role.id
}

output "iam_role_name" {
  value = aws_iam_role.instance_role.name
}

output "security_group_id" {
  value = aws_security_group.lc_security_group.id
}

output "s3_bucket_arn" {
  value = join(",", aws_s3_bucket.vault_storage.*.arn)
}

output "dynamo_table_arn" {
  value = element(concat(aws_dynamodb_table.vault_dynamo.*.arn, list("")), 0)
}

locals {
  domain_name              = var.domain_name != "" ? var.domain_name : "${var.name}-studio"
  model_package_group_name = var.model_package_group_name != "" ? var.model_package_group_name : "${var.name}-registry"
  execution_role_arn       = var.create_execution_role ? aws_iam_role.sagemaker[0].arn : var.default_execution_role_arn

  realtime_endpoints   = { for k, v in var.endpoints : k => v if v.type == "realtime" }
  serverless_endpoints = { for k, v in var.endpoints : k => v if v.type == "serverless" }
  async_endpoints      = { for k, v in var.endpoints : k => v if v.type == "async" }

  common_tags = merge(var.tags, {
    Module    = "terraform-aws-sagemaker-mlops"
    ManagedBy = "terraform"
  })
}

################################################################################
# Domain
################################################################################

output "domain_id" {
  description = "The ID of the SageMaker domain"
  value       = try(aws_sagemaker_domain.this[0].id, null)
}

output "domain_arn" {
  description = "The ARN of the SageMaker domain"
  value       = try(aws_sagemaker_domain.this[0].arn, null)
}

output "domain_url" {
  description = "The domain URL"
  value       = try(aws_sagemaker_domain.this[0].url, null)
}

################################################################################
# User Profiles
################################################################################

output "user_profile_arns" {
  description = "Map of user profile names to ARNs"
  value       = { for k, v in aws_sagemaker_user_profile.this : k => v.arn }
}

################################################################################
# Model Registry
################################################################################

output "model_package_group_arn" {
  description = "ARN of the model package group"
  value       = try(aws_sagemaker_model_package_group.this[0].arn, null)
}

################################################################################
# Pipelines
################################################################################

output "pipeline_arns" {
  description = "Map of pipeline names to ARNs"
  value       = { for k, v in aws_sagemaker_pipeline.this : k => v.arn }
}

################################################################################
# Endpoints
################################################################################

output "realtime_endpoint_names" {
  description = "Map of real-time endpoint names"
  value       = { for k, v in aws_sagemaker_endpoint.realtime : k => v.name }
}

output "realtime_endpoint_arns" {
  description = "Map of real-time endpoint ARNs"
  value       = { for k, v in aws_sagemaker_endpoint.realtime : k => v.arn }
}

output "serverless_endpoint_names" {
  description = "Map of serverless endpoint names"
  value       = { for k, v in aws_sagemaker_endpoint.serverless : k => v.name }
}

output "serverless_endpoint_arns" {
  description = "Map of serverless endpoint ARNs"
  value       = { for k, v in aws_sagemaker_endpoint.serverless : k => v.arn }
}

output "async_endpoint_names" {
  description = "Map of async endpoint names"
  value       = { for k, v in aws_sagemaker_endpoint.async : k => v.name }
}

output "async_endpoint_arns" {
  description = "Map of async endpoint ARNs"
  value       = { for k, v in aws_sagemaker_endpoint.async : k => v.arn }
}

################################################################################
# Feature Store
################################################################################

output "feature_group_names" {
  description = "Map of feature group names"
  value       = { for k, v in aws_sagemaker_feature_group.this : k => v.feature_group_name }
}

output "feature_group_arns" {
  description = "Map of feature group ARNs"
  value       = { for k, v in aws_sagemaker_feature_group.this : k => v.arn }
}

################################################################################
# Experiments
################################################################################

output "experiment_arns" {
  description = "Map of experiment ARNs"
  value       = { for k, v in aws_sagemaker_experiment.this : k => v.arn }
}

################################################################################
# IAM
################################################################################

output "execution_role_arn" {
  description = "ARN of the SageMaker execution role"
  value       = local.execution_role_arn
}

output "execution_role_name" {
  description = "Name of the SageMaker execution role"
  value       = try(aws_iam_role.sagemaker[0].name, null)
}

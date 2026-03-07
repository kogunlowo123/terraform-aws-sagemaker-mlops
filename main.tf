################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "sagemaker" {
  count = var.create_execution_role ? 1 : 0

  name               = "${var.name}-sagemaker-execution"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "sagemaker" {
  count = var.create_execution_role ? 1 : 0

  name   = "${var.name}-sagemaker-policy"
  role   = aws_iam_role.sagemaker[0].id
  policy = data.aws_iam_policy_document.sagemaker_policy[0].json
}

################################################################################
# SageMaker Domain
################################################################################

resource "aws_sagemaker_domain" "this" {
  count = var.create_domain ? 1 : 0

  domain_name = local.domain_name
  auth_mode   = var.auth_mode
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  app_network_access_type = var.app_network_access_type

  default_user_settings {
    execution_role = local.execution_role_arn
  }

  tags = local.common_tags
}

################################################################################
# User Profiles
################################################################################

resource "aws_sagemaker_user_profile" "this" {
  for_each = var.create_domain ? var.user_profiles : {}

  domain_id         = aws_sagemaker_domain.this[0].id
  user_profile_name = each.key

  user_settings {
    execution_role = coalesce(each.value.execution_role_arn, local.execution_role_arn)
  }

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Model Registry
################################################################################

resource "aws_sagemaker_model_package_group" "this" {
  count = var.create_model_registry ? 1 : 0

  model_package_group_name        = local.model_package_group_name
  model_package_group_description = var.model_package_group_description

  tags = local.common_tags
}

################################################################################
# Pipelines
################################################################################

resource "aws_sagemaker_pipeline" "this" {
  for_each = var.pipelines

  pipeline_name         = "${var.name}-${each.key}"
  pipeline_display_name = each.key
  role_arn              = each.value.role_arn

  pipeline_definition = each.value.pipeline_definition

  pipeline_definition_s3_location {
    bucket = each.value.definition_s3_uri != null ? split("/", replace(each.value.definition_s3_uri, "s3://", ""))[0] : null
    object_key = each.value.definition_s3_uri != null ? join("/", slice(
      split("/", replace(each.value.definition_s3_uri, "s3://", "")),
      1,
      length(split("/", replace(each.value.definition_s3_uri, "s3://", "")))
    )) : null
  }

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Endpoint Configuration - Real-time
################################################################################

resource "aws_sagemaker_endpoint_configuration" "realtime" {
  for_each = local.realtime_endpoints

  name = "${var.name}-${each.key}-config"

  production_variants {
    variant_name           = each.value.variant_name
    model_name             = each.value.model_name
    instance_type          = each.value.instance_type
    initial_instance_count = each.value.instance_count
    initial_variant_weight = each.value.initial_variant_weight
  }

  dynamic "data_capture_config" {
    for_each = each.value.data_capture_percent > 0 ? [1] : []

    content {
      enable_capture              = true
      initial_sampling_percentage = each.value.data_capture_percent
      destination_s3_uri          = each.value.data_capture_s3_uri

      capture_options {
        capture_mode = "Input"
      }

      capture_options {
        capture_mode = "Output"
      }
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Endpoint Configuration - Serverless
################################################################################

resource "aws_sagemaker_endpoint_configuration" "serverless" {
  for_each = local.serverless_endpoints

  name = "${var.name}-${each.key}-config"

  production_variants {
    variant_name = each.value.variant_name
    model_name   = each.value.model_name

    serverless_config {
      max_concurrency   = each.value.serverless_max_concurrency
      memory_size_in_mb = each.value.serverless_memory_size
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Endpoint Configuration - Async
################################################################################

resource "aws_sagemaker_endpoint_configuration" "async" {
  for_each = local.async_endpoints

  name = "${var.name}-${each.key}-config"

  production_variants {
    variant_name           = each.value.variant_name
    model_name             = each.value.model_name
    instance_type          = each.value.instance_type
    initial_instance_count = each.value.instance_count
  }

  async_inference_config {
    output_config {
      s3_output_path = each.value.async_output_s3_uri

      dynamic "notification_config" {
        for_each = each.value.async_sns_topic_arn != "" ? [1] : []

        content {
          success_topic = each.value.async_sns_topic_arn
          error_topic   = each.value.async_sns_topic_arn
        }
      }
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Endpoints
################################################################################

resource "aws_sagemaker_endpoint" "realtime" {
  for_each = local.realtime_endpoints

  name                 = "${var.name}-${each.key}"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.realtime[each.key].name

  tags = merge(local.common_tags, each.value.tags)
}

resource "aws_sagemaker_endpoint" "serverless" {
  for_each = local.serverless_endpoints

  name                 = "${var.name}-${each.key}"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.serverless[each.key].name

  tags = merge(local.common_tags, each.value.tags)
}

resource "aws_sagemaker_endpoint" "async" {
  for_each = local.async_endpoints

  name                 = "${var.name}-${each.key}"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.async[each.key].name

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Feature Store
################################################################################

resource "aws_sagemaker_feature_group" "this" {
  for_each = var.create_feature_store ? var.feature_groups : {}

  feature_group_name             = "${var.name}-${each.key}"
  record_identifier_feature_name = each.value.record_identifier_name
  event_time_feature_name        = each.value.event_time_name
  role_arn                       = each.value.role_arn

  dynamic "feature_definition" {
    for_each = each.value.features

    content {
      feature_name = feature_definition.value.name
      feature_type = feature_definition.value.type
    }
  }

  dynamic "online_store_config" {
    for_each = each.value.online_store_enabled ? [1] : []

    content {
      enable_online_store = true
    }
  }

  dynamic "offline_store_config" {
    for_each = each.value.offline_store_s3_uri != "" ? [1] : []

    content {
      s3_storage_config {
        s3_uri = each.value.offline_store_s3_uri
      }
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Experiments
################################################################################

resource "aws_sagemaker_experiment" "this" {
  for_each = var.create_experiments ? var.experiments : {}

  experiment_name = "${var.name}-${each.key}"
  description     = each.value.description

  tags = merge(local.common_tags, each.value.tags)
}

################################################################################
# Model Monitoring
################################################################################

resource "aws_sagemaker_monitoring_schedule" "this" {
  for_each = var.create_model_monitoring ? var.monitoring_schedules : {}

  name = "${var.name}-${each.key}-monitoring"

  monitoring_schedule_config {
    monitoring_job_definition_name = "${var.name}-${each.key}-job"
    monitoring_type                = "DataQuality"

    schedule_config {
      schedule_expression = each.value.schedule_expression
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

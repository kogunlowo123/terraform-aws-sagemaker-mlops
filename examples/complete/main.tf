provider "aws" {
  region = "us-east-1"
}

module "sagemaker_mlops" {
  source = "../../"

  name       = "ml-production"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  create_domain           = true
  auth_mode               = "IAM"
  create_execution_role   = true
  app_network_access_type = "VpcOnly"

  user_profiles = {
    lead-data-scientist = {
      tags = { Role = "lead", Team = "data-science" }
    }
    ml-engineer-1 = {
      tags = { Role = "engineer", Team = "mlops" }
    }
    ml-engineer-2 = {
      tags = { Role = "engineer", Team = "mlops" }
    }
    analyst = {
      tags = { Role = "analyst", Team = "analytics" }
    }
  }

  create_model_registry           = true
  model_package_group_name        = "production-models"
  model_package_group_description = "Production model registry with approval workflows"

  pipelines = {
    training = {
      role_arn    = "arn:aws:iam::123456789012:role/sagemaker-pipeline"
      description = "Model training pipeline"
      pipeline_definition = jsonencode({
        Version = "2020-12-01"
        Steps = [
          {
            Name = "ProcessingStep"
            Type = "Processing"
          }
        ]
      })
    }
  }

  endpoints = {
    primary = {
      type                 = "realtime"
      model_name           = "production-model"
      instance_type        = "ml.m5.2xlarge"
      instance_count       = 3
      data_capture_percent = 100
      data_capture_s3_uri  = "s3://ml-production-bucket/data-capture/"
    }
    low-latency = {
      type                       = "serverless"
      model_name                 = "lightweight-model"
      serverless_max_concurrency = 20
      serverless_memory_size     = 6144
    }
    batch-processing = {
      type                = "async"
      model_name          = "batch-model"
      instance_type       = "ml.m5.4xlarge"
      instance_count      = 2
      async_output_s3_uri = "s3://ml-production-bucket/async-output/"
      async_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:ml-notifications"
    }
  }

  create_feature_store = true
  feature_groups = {
    user-features = {
      record_identifier_name = "user_id"
      event_time_name        = "timestamp"
      role_arn               = "arn:aws:iam::123456789012:role/sagemaker-feature-store"
      online_store_enabled   = true
      offline_store_s3_uri   = "s3://ml-production-bucket/feature-store/user-features/"
      features = [
        { name = "user_id", type = "String" },
        { name = "timestamp", type = "Fractional" },
        { name = "purchase_count", type = "Integral" },
        { name = "avg_order_value", type = "Fractional" },
        { name = "lifetime_value", type = "Fractional" },
        { name = "churn_risk", type = "Fractional" },
      ]
    }
    product-features = {
      record_identifier_name = "product_id"
      event_time_name        = "timestamp"
      role_arn               = "arn:aws:iam::123456789012:role/sagemaker-feature-store"
      online_store_enabled   = true
      offline_store_s3_uri   = "s3://ml-production-bucket/feature-store/product-features/"
      features = [
        { name = "product_id", type = "String" },
        { name = "timestamp", type = "Fractional" },
        { name = "category", type = "String" },
        { name = "price", type = "Fractional" },
        { name = "rating", type = "Fractional" },
      ]
    }
  }

  create_experiments = true
  experiments = {
    recommender-v2 = {
      description = "Recommender system v2 experiments"
    }
    churn-prediction = {
      description = "Customer churn prediction experiments"
    }
  }

  create_model_monitoring = true
  monitoring_schedules = {
    primary-monitor = {
      endpoint_name       = "ml-production-primary"
      role_arn            = "arn:aws:iam::123456789012:role/sagemaker-monitoring"
      output_s3_uri       = "s3://ml-production-bucket/monitoring/"
      schedule_expression = "cron(0 */6 ? * * *)"
      instance_type       = "ml.m5.xlarge"
    }
  }

  tags = {
    Environment = "production"
    Project     = "ml-platform"
    CostCenter  = "ml-ops"
  }
}

output "domain_id" {
  value = module.sagemaker_mlops.domain_id
}

output "domain_url" {
  value = module.sagemaker_mlops.domain_url
}

output "endpoint_names" {
  value = module.sagemaker_mlops.realtime_endpoint_names
}

output "execution_role_arn" {
  value = module.sagemaker_mlops.execution_role_arn
}

provider "aws" {
  region = "us-east-1"
}

module "sagemaker_mlops" {
  source = "../../"

  name       = "ml-advanced"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

  create_domain         = true
  auth_mode             = "IAM"
  create_execution_role = true

  app_network_access_type = "VpcOnly"

  user_profiles = {
    lead-scientist = {
      tags = { Role = "lead" }
    }
    ml-engineer = {
      tags = { Role = "engineer" }
    }
  }

  create_model_registry           = true
  model_package_group_description = "Advanced ML model registry"

  endpoints = {
    inference = {
      type           = "realtime"
      model_name     = "my-trained-model"
      instance_type  = "ml.m5.xlarge"
      instance_count = 2
    }
    batch-api = {
      type                       = "serverless"
      model_name                 = "my-trained-model"
      serverless_max_concurrency = 10
      serverless_memory_size     = 4096
    }
  }

  create_feature_store = true
  feature_groups = {
    customer-features = {
      record_identifier_name = "customer_id"
      event_time_name        = "event_time"
      role_arn               = "arn:aws:iam::123456789012:role/sagemaker-feature-store"
      online_store_enabled   = true
      offline_store_s3_uri   = "s3://my-bucket/feature-store/"
      features = [
        { name = "customer_id", type = "String" },
        { name = "event_time", type = "Fractional" },
        { name = "age", type = "Integral" },
        { name = "spend_score", type = "Fractional" },
      ]
    }
  }

  create_experiments = true
  experiments = {
    model-tuning = {
      description = "Hyperparameter tuning experiments"
    }
  }

  tags = {
    Environment = "staging"
    Project     = "ml-advanced"
  }
}

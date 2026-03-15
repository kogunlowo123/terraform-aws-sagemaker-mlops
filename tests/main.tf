module "test" {
  source = "../"

  name = "test-mlops"

  tags = {
    Project     = "sagemaker-mlops-test"
    Environment = "test"
  }

  # SageMaker Domain
  create_domain          = true
  domain_name            = "test-mlops-domain"
  auth_mode              = "IAM"
  vpc_id                 = "vpc-0abc1234def567890"
  subnet_ids             = ["subnet-0abc1234def567890", "subnet-0abc1234def567891"]
  app_network_access_type = "PublicInternetOnly"

  # IAM
  create_execution_role = true

  # Model Registry
  create_model_registry          = true
  model_package_group_name       = "test-model-registry"
  model_package_group_description = "Test model registry for MLOps"

  # Feature Store (disabled for basic test)
  create_feature_store = false

  # Experiments (disabled for basic test)
  create_experiments = false

  # Model Monitoring (disabled for basic test)
  create_model_monitoring = false
}

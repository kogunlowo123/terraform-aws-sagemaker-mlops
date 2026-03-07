provider "aws" {
  region = "us-east-1"
}

module "sagemaker_mlops" {
  source = "../../"

  name       = "my-ml-project"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

  create_domain         = true
  auth_mode             = "IAM"
  create_execution_role = true

  create_model_registry = true

  user_profiles = {
    data-scientist = {}
  }

  tags = {
    Environment = "dev"
    Project     = "ml-basic"
  }
}

output "domain_id" {
  value = module.sagemaker_mlops.domain_id
}

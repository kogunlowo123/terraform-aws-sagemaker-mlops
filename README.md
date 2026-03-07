# terraform-aws-sagemaker-mlops

Terraform module for deploying a comprehensive AWS SageMaker MLOps platform with model registry, pipelines, endpoints, feature store, experiments, and model monitoring.

## Architecture

```mermaid
flowchart TD
    A[SageMaker Domain] --> B[User Profiles]
    A --> C[Model Registry]
    A --> D[Pipelines]
    A --> E[Endpoints]
    A --> F[Feature Store]
    A --> G[Experiments]
    A --> H[Model Monitoring]

    D --> D1[Training Pipeline]
    D --> D2[Processing Pipeline]

    E --> E1[Real-time Endpoint]
    E --> E2[Serverless Endpoint]
    E --> E3[Async Endpoint]

    E1 --> I[Data Capture]
    I --> J[S3 Bucket]

    F --> F1[Online Store]
    F --> F2[Offline Store]
    F2 --> J

    H --> H1[Data Quality Monitor]
    H --> H2[Model Quality Monitor]
    H1 --> J
    H2 --> J

    C --> K[Model Approval]
    K --> E

    G --> G1[Experiment Tracking]
    G --> G2[Trial Components]

    L[IAM Execution Role] --> A
    L --> D
    L --> E

    style A fill:#FF6B35,stroke:#D4531E,color:#FFFFFF
    style B fill:#4A90D9,stroke:#2E6BA6,color:#FFFFFF
    style C fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style D fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style E fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style F fill:#F39C12,stroke:#E67E22,color:#FFFFFF
    style G fill:#1ABC9C,stroke:#16A085,color:#FFFFFF
    style H fill:#E91E63,stroke:#C2185B,color:#FFFFFF
    style D1 fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style D2 fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style E1 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style E2 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style E3 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style F1 fill:#F39C12,stroke:#E67E22,color:#FFFFFF
    style F2 fill:#F39C12,stroke:#E67E22,color:#FFFFFF
    style H1 fill:#E91E63,stroke:#C2185B,color:#FFFFFF
    style H2 fill:#E91E63,stroke:#C2185B,color:#FFFFFF
    style I fill:#3498DB,stroke:#2980B9,color:#FFFFFF
    style J fill:#34495E,stroke:#2C3E50,color:#FFFFFF
    style K fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style L fill:#95A5A6,stroke:#7F8C8D,color:#FFFFFF
    style G1 fill:#1ABC9C,stroke:#16A085,color:#FFFFFF
    style G2 fill:#1ABC9C,stroke:#16A085,color:#FFFFFF
```

## Features

- **SageMaker Domain** - Managed Studio environment with IAM/SSO authentication
- **User Profiles** - Multi-user support with per-user execution roles
- **Model Registry** - Model package groups for versioning and approval workflows
- **Pipelines** - ML pipeline orchestration with inline or S3-based definitions
- **Endpoints** - Real-time, serverless, and async inference endpoints
- **Feature Store** - Online and offline feature storage
- **Experiments** - Experiment tracking and trial components
- **Model Monitoring** - Data quality and model quality monitoring schedules
- **IAM** - Auto-provisioned execution roles with least-privilege policies

## Usage

```hcl
module "sagemaker_mlops" {
  source = "path/to/terraform-aws-sagemaker-mlops"

  name       = "my-ml-project"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-abc", "subnet-def"]

  user_profiles = {
    data-scientist = {}
  }

  endpoints = {
    inference = {
      type       = "realtime"
      model_name = "my-model"
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

## Examples

- [Basic](examples/basic/) - Domain with user profile and model registry
- [Advanced](examples/advanced/) - Endpoints, feature store, and experiments
- [Complete](examples/complete/) - Full MLOps platform with monitoring

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5.0 |
| aws       | >= 5.0   |

## License

MIT License - see [LICENSE](LICENSE) for details.

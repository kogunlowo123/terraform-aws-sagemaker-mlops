variable "name" {
  description = "Name prefix for all resources."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "create_domain" {
  description = "Whether to create the SageMaker domain."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Name of the SageMaker domain."
  type        = string
  default     = ""
}

variable "auth_mode" {
  description = "Authentication mode for the domain (IAM or SSO)."
  type        = string
  default     = "IAM"

  validation {
    condition     = contains(["IAM", "SSO"], var.auth_mode)
    error_message = "auth_mode must be IAM or SSO."
  }
}

variable "vpc_id" {
  description = "VPC ID for the SageMaker domain."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the SageMaker domain."
  type        = list(string)
}

variable "app_network_access_type" {
  description = "Network access type for apps (PublicInternetOnly or VpcOnly)."
  type        = string
  default     = "PublicInternetOnly"
}

variable "default_execution_role_arn" {
  description = "Default execution role ARN for the domain."
  type        = string
  default     = ""
}

variable "user_profiles" {
  description = "Map of user profiles to create."
  type = map(object({
    execution_role_arn = optional(string)
    tags               = optional(map(string), {})
  }))
  default = {}
}

variable "create_model_registry" {
  description = "Whether to create a model package group."
  type        = bool
  default     = true
}

variable "model_package_group_name" {
  description = "Name of the model package group."
  type        = string
  default     = ""
}

variable "model_package_group_description" {
  description = "Description of the model package group."
  type        = string
  default     = "MLOps model registry"
}

variable "pipelines" {
  description = "Map of SageMaker pipelines to create."
  type = map(object({
    role_arn            = string
    pipeline_definition = optional(string)
    definition_s3_uri   = optional(string)
    description         = optional(string, "")
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "endpoints" {
  description = "Map of SageMaker endpoints to create."
  type = map(object({
    type                       = optional(string, "realtime")
    model_name                 = string
    instance_type              = optional(string, "ml.m5.large")
    instance_count             = optional(number, 1)
    serverless_max_concurrency = optional(number, 5)
    serverless_memory_size     = optional(number, 2048)
    async_output_s3_uri        = optional(string, "")
    async_sns_topic_arn        = optional(string, "")
    variant_name               = optional(string, "primary")
    initial_variant_weight     = optional(number, 1)
    data_capture_percent       = optional(number, 0)
    data_capture_s3_uri        = optional(string, "")
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "create_feature_store" {
  description = "Whether to create feature store groups."
  type        = bool
  default     = false
}

variable "feature_groups" {
  description = "Map of feature groups to create."
  type = map(object({
    record_identifier_name = string
    event_time_name        = string
    role_arn               = string
    features = list(object({
      name = string
      type = string
    }))
    online_store_enabled = optional(bool, true)
    offline_store_s3_uri = optional(string, "")
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "create_experiments" {
  description = "Whether to create experiment tracking."
  type        = bool
  default     = false
}

variable "experiments" {
  description = "Map of experiments to create."
  type = map(object({
    description = optional(string, "")
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "create_model_monitoring" {
  description = "Whether to create model monitoring schedules."
  type        = bool
  default     = false
}

variable "monitoring_schedules" {
  description = "Map of monitoring schedules to create."
  type = map(object({
    endpoint_name               = string
    role_arn                    = string
    output_s3_uri               = string
    schedule_expression         = optional(string, "cron(0 * ? * * *)")
    instance_type               = optional(string, "ml.m5.xlarge")
    instance_count              = optional(number, 1)
    max_runtime_seconds         = optional(number, 3600)
    baseline_constraints_s3_uri = optional(string, "")
    baseline_statistics_s3_uri  = optional(string, "")
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "create_execution_role" {
  description = "Whether to create a default SageMaker execution role."
  type        = bool
  default     = true
}

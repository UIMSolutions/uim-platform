module uim.platform.data.attribute_recommendation.application.dto;

import uim.platform.data.attribute_recommendation.domain.types;

// --- Dataset ---

struct CreateDatasetRequest
{
  TenantId tenantId;
  string name;
  string description;
  DataType dataType;
  string columnDefinitions; // JSON
  UserId createdBy;
}

struct UpdateDatasetRequest
{
  DatasetId id;
  TenantId tenantId;
  string name;
  string description;
  string columnDefinitions;
}

// --- Data Record ---

struct CreateDataRecordRequest
{
  DatasetId datasetId;
  TenantId tenantId;
  string attributes; // JSON
  string labels;     // JSON
  UserId createdBy;
}

struct CreateBulkRecordsRequest
{
  DatasetId datasetId;
  TenantId tenantId;
  string records; // JSON array of {attributes, labels}
  UserId createdBy;
}

// --- Model Configuration ---

struct CreateModelConfigRequest
{
  TenantId tenantId;
  DatasetId datasetId;
  string name;
  string description;
  ModelType modelType;
  string targetColumns;   // JSON array
  string featureColumns;  // JSON array
  string hyperparameters; // JSON
  UserId createdBy;
}

struct UpdateModelConfigRequest
{
  ModelConfigId id;
  TenantId tenantId;
  string name;
  string description;
  ModelType modelType;
  string targetColumns;
  string featureColumns;
  string hyperparameters;
}

// --- Training Job ---

struct StartTrainingRequest
{
  ModelConfigId modelConfigId;
  TenantId tenantId;
  UserId createdBy;
}

// --- Model Deployment ---

struct CreateDeploymentRequest
{
  TenantId tenantId;
  TrainingJobId trainingJobId;
  string name;
  int replicas;
  UserId createdBy;
}

// --- Inference ---

struct SubmitInferenceRequest
{
  TenantId tenantId;
  DeploymentId deploymentId;
  string inputData; // JSON
}

// --- Command Result ---

struct CommandResult
{
  string id;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

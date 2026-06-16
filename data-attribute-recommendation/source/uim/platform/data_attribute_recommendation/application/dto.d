/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.dto;

import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
struct CreateDatasetRequest {
  TenantId tenantId;
  string name;
  string description;
  string dataType;
  string columnDefinitions; // JSON
  UserId createdBy;
}

struct UpdateDatasetRequest {
  DatasetId datasetId;
  TenantId tenantId;
  string name;
  string description;
  string columnDefinitions;
}
// --- Data Record ---

struct CreateDataRecordRequest {
  DatasetId datasetId;
  TenantId tenantId;
  string attributes; // JSON
  string labels; // JSON
  UserId createdBy;
}

struct CreateBulkRecordsRequest {
  DatasetId datasetId;
  TenantId tenantId;
  string records; // JSON array of {attributes, labels}
  UserId createdBy;
}
// --- Model Configuration ---

struct CreateModelConfigRequest {
  TenantId tenantId;
  DatasetId datasetId;
  string name;
  string description;
  string modelType;
  string targetColumns; // JSON array
  string featureColumns; // JSON array
  string hyperparameters; // JSON
  UserId createdBy;
}

struct UpdateModelConfigRequest {
  ModelConfigurationId configId;
  TenantId tenantId;
  string name;
  string description;
  string modelType;
  string targetColumns;
  string featureColumns;
  string hyperparameters;
}
// --- Training Job ---

struct StartTrainingRequest {
  ModelConfigurationId configId;
  TenantId tenantId;
  UserId createdBy;
}
// --- Model Deployment ---

struct CreateDeploymentRequest {
  TenantId tenantId;
  TrainingJobId jobId;
  string name;
  int replicas;
  UserId createdBy;
}
// --- Inference ---

struct SubmitInferenceRequest {
  TenantId tenantId;
  DeploymentId deploymentId;
  string inputData; // JSON
}
// --- Command Result ---



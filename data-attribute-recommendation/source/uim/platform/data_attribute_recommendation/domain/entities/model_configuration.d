module uim.platform.data_attribute_recommendation.domain.entities.model_configuration;

import uim.platform.data_attribute_recommendation.domain.types;

/// Configuration for a machine-learning model that defines which dataset
/// to train on, which columns are features/targets, and hyperparameters.
struct ModelConfiguration
{
  ModelConfigId id;
  TenantId tenantId;
  DatasetId datasetId;
  string name;
  string description;
  ModelType modelType = ModelType.classification;
  string targetColumns;   // JSON array of column names
  string featureColumns;  // JSON array of column names
  string hyperparameters; // JSON: {learningRate, epochs, batchSize, ...}
  ModelConfigStatus status = ModelConfigStatus.draft;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}

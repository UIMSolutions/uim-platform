/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.model_configuration;

import uim.platform.data.attribute_recommendation.domain.types;

/// Configuration for a machine-learning model that defines which dataset
/// to train on, which columns are features/targets, and hyperparameters.
struct ModelConfiguration {
  mixin TenantEntity!(ModelConfigId);

  DatasetId datasetId;
  string name;
  string description;
  ModelType modelType = ModelType.classification;
  string targetColumns; // JSON array of column names
  string featureColumns; // JSON array of column names
  string hyperparameters; // JSON: {learningRate, epochs, batchSize, ...}
  ModelConfigStatus status = ModelConfigStatus.draft;

  Json toJson() const {
    return entityToJson
      .set("datasetId", datasetId)
      .set("name", name)
      .set("description", description)
      .set("modelType", modelType.to!string)
      .set("targetColumns", targetColumns)
      .set("featureColumns", featureColumns)
      .set("hyperparameters", hyperparameters)
      .set("status", status.to!string);
  }
}

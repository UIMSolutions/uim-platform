/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.enumerations;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:

enum DatasetStatus {
  draft,
  ready,
  processing,
  completed,
  failed
}
DatasetStatus toDatasetStatus(string s) {
  switch (s.lower) {
  case "draft":
    return DatasetStatus.draft;
  case "ready":
    return DatasetStatus.ready;
  case "processing":
    return DatasetStatus.processing;
  case "completed":
    return DatasetStatus.completed;
  case "failed":
    return DatasetStatus.failed;
  default:
    return DatasetStatus.draft;
  }
}

enum DataType {
  product,
  material,
  customer,
  supplier,
  custom
}

DataType toDataType(string s) {
  switch (s.lower) {
  case "product":
    return DataType.product;
  case "material":
    return DataType.material;
  case "customer":
    return DataType.customer;
  case "supplier":
    return DataType.supplier;
  case "custom":
    return DataType.custom;
  default:
    return DataType.custom;
  }
}
enum RecordStatus {
  pending,
  validated,
  rejected
}
RecordStatus toRecordStatus(string s) {
  switch (s.lower) {
  case "pending":
    return RecordStatus.pending;
  case "validated":
    return RecordStatus.validated;
  case "rejected":
    return RecordStatus.rejected;
  default:
    return RecordStatus.pending;
  }
}

enum ModelType {
  classification,
  regression,
  recommendation
}

ModelType toModelType(string s) {
  switch (s.toLower()) {
  case "classification":
    return ModelType.classification;
  case "regression":
    return ModelType.regression;
  case "recommendation":
    return ModelType.recommendation;
  default:
    return ModelType.classification;
  }
}

enum ModelConfigStatus {
  draft,
  ready,
  training,
  trained,
  failed
}
ModelConfigStatus toModelConfigStatus(string s) {
  switch (s.toLower()) {
  case "draft":
    return ModelConfigStatus.draft;
  case "ready":
    return ModelConfigStatus.ready;
  case "training":
    return ModelConfigStatus.training;
  case "trained":
    return ModelConfigStatus.trained;
  case "failed":
    return ModelConfigStatus.failed;
  default:
    return ModelConfigStatus.draft;
  }
}

enum JobStatus {
  queued,
  running,
  completed,
  failed,
  cancelled
}

JobStatus toJobStatus(string s) {
  switch (s.toLower()) {
  case "queued":
    return JobStatus.queued;
  case "running":
    return JobStatus.running;
  case "completed":
    return JobStatus.completed;
  case "failed":
    return JobStatus.failed;
  case "cancelled":
    return JobStatus.cancelled;
  default:
    return JobStatus.queued;
  }
}

enum DeploymentStatus {
  deploying,
  active,
  inactive,
  failed
}

DeploymentStatus toDeploymentStatus(string s) {
  switch (s.toLower()) {
  case "deploying":
    return DeploymentStatus.deploying;
  case "active":
    return DeploymentStatus.active;
  case "inactive":
    return DeploymentStatus.inactive;
  case "failed":
    return DeploymentStatus.failed;
  default:
    return DeploymentStatus.inactive;
  }
}

enum InferenceStatus {
  pending,
  processing,
  completed,
  failed
}

InferenceStatus toInferenceStatus(string s) {
  switch (s.toLower()) {
  case "pending":
    return InferenceStatus.pending;
  case "processing":
    return InferenceStatus.processing;
  case "completed":
    return InferenceStatus.completed;
  case "failed":
    return InferenceStatus.failed;
  default:
    return InferenceStatus.pending;
  }
}
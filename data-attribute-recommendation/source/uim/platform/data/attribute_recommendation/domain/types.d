/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.types;

// --- Type aliases ---
struct DatasetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DataRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ModelConfigId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TrainingJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DeploymentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct InferenceRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct InferenceResultId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}





// --- Enums ---

enum DatasetStatus {
  draft,
  ready,
  processing,
  completed,
  failed
}

enum DataType {
  product,
  material,
  customer,
  supplier,
  custom
}

DataType parseDataType(string s) {
  switch (s) {
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

enum ModelType {
  classification,
  regression,
  recommendation
}

ModelType parseModelType(string s) {
  switch (s) {
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

enum JobStatus {
  queued,
  running,
  completed,
  failed,
  cancelled
}

enum DeploymentStatus {
  deploying,
  active,
  inactive,
  failed
}

enum InferenceStatus {
  pending,
  processing,
  completed,
  failed
}

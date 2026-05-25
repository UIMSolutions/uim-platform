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

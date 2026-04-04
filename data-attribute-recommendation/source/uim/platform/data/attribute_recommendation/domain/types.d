/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.types;

// --- Type aliases ---
alias DatasetId = string;
alias DataRecordId = string;
alias ModelConfigId = string;
alias TrainingJobId = string;
alias DeploymentId = string;
alias InferenceRequestId = string;
alias InferenceResultId = string;
alias TenantId = string;
alias UserId = string;

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

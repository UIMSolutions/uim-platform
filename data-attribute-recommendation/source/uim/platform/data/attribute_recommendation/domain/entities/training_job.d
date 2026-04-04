/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.training_job;

import uim.platform.data.attribute_recommendation.domain.types;

/// Represents a single training run of a model configuration, tracking
/// progress, metrics, and completion status.
struct TrainingJob {
  TrainingJobId id;
  TenantId tenantId;
  ModelConfigId modelConfigId;
  JobStatus status = JobStatus.queued;
  string metrics; // JSON: {accuracy, precision, recall, f1Score}
  int epochsCompleted;
  int totalEpochs;
  string errorMessage;
  long startedAt;
  long completedAt;
  UserId createdBy;
  long createdAt;
}

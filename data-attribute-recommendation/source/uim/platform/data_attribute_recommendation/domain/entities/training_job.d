/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.entities.training_job;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
/// Represents a single training run of a model configuration, tracking
/// progress, metrics, and completion status.
struct TrainingJob {
  mixin TenantEntity!TrainingJobId;
  ModelConfigurationId modelConfigId;

  JobStatus status = JobStatus.queued;
  string metrics; // JSON: {accuracy, precision, recall, f1Score}
  int epochsCompleted;
  int totalEpochs;
  string errorMessage;
  long startedAt;
  long completedAt;

  Json toJson() const {
    return entityToJson
      .set("modelConfigId", modelConfigId)
      .set("status", status.to!string())
      .set("metrics", metrics)
      .set("epochsCompleted", epochsCompleted)
      .set("totalEpochs", totalEpochs)
      .set("errorMessage", errorMessage)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt);
  }
}

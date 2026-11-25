/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A training job: improves the extraction model of a schema with the
/// confirmed documents (and their corrections). pending → running →
/// completed | failed; pending/running → cancelled.
module uim.platform.document_ai.domain.entities.training_job;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct TrainingJob {
  mixin TenantEntity!TrainingJobId;

  ClientId clientId; /// optional
  DocumentTypeId documentTypeId; /// optional
  SchemaId schemaId;
  string name;
  string description;
  TrainingJobStatus status = TrainingJobStatus.pending;
  string statusMessage;
  string modelVersion; /// assigned on completion, e.g. "invoice-v2"
  int documentCount; /// confirmed documents used
  int fieldCount; /// values used
  double accuracy = 0; /// share of values that needed no correction (0 … 1)
  long startedAt;
  long completedAt;

  void start(int documents, int fields, long now) {
    if (status != TrainingJobStatus.pending && status != TrainingJobStatus.failed && status != TrainingJobStatus.cancelled)
      throw DaiException.ruleViolation("Training job '" ~ id.value ~ "' is " ~ cast(string) status ~ " and cannot be started");
    status = TrainingJobStatus.running;
    documentCount = documents;
    fieldCount = fields;
    startedAt = now;
    completedAt = 0;
    accuracy = 0;
    statusMessage = format("Training with %d confirmed documents (%d values)", documents, fields);
  }

  void complete(double accuracy_, string version_, long now) {
    if (status != TrainingJobStatus.running)
      throw DaiException.ruleViolation("Training job '" ~ id.value ~ "' is not running");
    status = TrainingJobStatus.completed;
    accuracy = accuracy_;
    modelVersion = version_;
    completedAt = now;
    statusMessage = format("Model %s trained, accuracy %.1f %%", version_, accuracy_ * 100);
  }

  void fail(string message, long now) {
    status = TrainingJobStatus.failed;
    completedAt = now;
    statusMessage = message;
  }

  void cancel(long now) {
    if (!isOpen(status))
      throw DaiException.ruleViolation("Training job '" ~ id.value ~ "' is " ~ cast(string) status ~ " and cannot be cancelled");
    status = TrainingJobStatus.cancelled;
    completedAt = now;
    statusMessage = "Cancelled";
  }

  /// 0 … 100 (running: elapsed / duration).
  int progressPercent(long now, long durationSeconds) const {
    if (status == TrainingJobStatus.completed)
      return 100;
    if (status != TrainingJobStatus.running || durationSeconds <= 0)
      return 0;
    auto elapsed = (now - startedAt) / hnsecsPerSecondL;
    return cast(int) clamp(elapsed * 100 / durationSeconds, 0, 99);
  }

  void validate() const {
    requireId(id.value, "Training job ID");
    requireText(schemaId.value, "Schema");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
  }
}

///
unittest {
  TrainingJob j;
  j.id = TrainingJobId("j1");
  j.schemaId = SchemaId("inv");
  j.name = "Invoices";
  j.validate();
  assert(failsWith(DaiErrorKind.ruleViolation, () { j.complete(1, "v", 1); }));
  j.start(3, 30, plusSeconds(0, 100));
  assert(j.progressPercent(plusSeconds(0, 130), 60) == 50);
  j.complete(0.9, "inv-v1", 5);
  assert(j.status == TrainingJobStatus.completed && j.progressPercent(0, 60) == 100);
  assert(failsWith(DaiErrorKind.ruleViolation, () { j.cancel(6); }));
}

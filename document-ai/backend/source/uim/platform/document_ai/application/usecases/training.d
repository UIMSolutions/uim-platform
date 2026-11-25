/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Training jobs: train the extraction model of a schema with the
/// confirmed documents (of clients that allow data feedback).
///
/// Rules: one running job per schema; starting needs an active (or
/// deprecated) schema and policy.minTrainingDocuments confirmed documents;
/// jobs run policy.trainingSeconds (simulated) and are completed by the
/// background worker; running jobs cannot be changed or deleted.
module uim.platform.document_ai.application.usecases.training;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageTrainingJobsUseCase : ResourceInteractor!(TrainingJob, TrainingJobId, TrainingJobInput), IManageTrainingJobs {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(TrainingJob, TrainingJobId) store() {
    return repos.trainingJobs;
  }

  protected override string what() {
    return "Training job";
  }

  protected override string eventPrefix() {
    return "training";
  }

  protected override string[] immutableAttributes() {
    return ["schemaId"];
  }

  protected override TrainingJobInput toInput(const TrainingJob e) {
    TrainingJobInput i;
    i.clientId = e.clientId.value;
    i.documentTypeId = e.documentTypeId.value;
    i.schemaId = e.schemaId.value;
    i.name = e.name;
    i.description = e.description;
    return i;
  }

  protected override void beforeUpdate(TenantId t, const TrainingJob e) {
    if (e.status == TrainingJobStatus.running)
      throw DaiException.ruleViolation("Training job '" ~ e.name ~ "' is running");
  }

  protected override void fromInput(TenantId t, ref TrainingJob e, TrainingJobInput i, bool creating) {
    e.clientId = ClientId(optionalReference!ClientId(repos.clients, t, i.clientId, "Client"));
    e.documentTypeId = DocumentTypeId(optionalReference!DocumentTypeId(repos.documentTypes, t, i.documentTypeId, "Document type"));
    e.schemaId = schemaOf(t, SchemaId(i.schemaId.strip)).id;
    e.name = i.name.strip;
    e.description = i.description.strip;
  }

  protected override void beforeRemove(TenantId t, const TrainingJob e, UserId actor) {
    if (e.status == TrainingJobStatus.running)
      throw DaiException.ruleViolation("Training job '" ~ e.name ~ "' is running — cancel it first");
  }

  /// The training data of a job: confirmed documents of the schema (and
  /// client / document type of the job) whose client allows data feedback.
  protected TrainingData dataOf(TenantId t, const TrainingJob job) {
    bool[string] feedback;
    foreach (c; repos.clients.findAll(t))
      feedback[c.id.value] = c.dataFeedbackEnabled;
    AiDocument[] docs;
    foreach (d; repos.documents.findByReference(t, "schemaId", job.schemaId.value))
      if (d.status == DocumentStatus.confirmed && (job.clientId.isNull || d.clientId == job.clientId)
        && (job.documentTypeId.isNull || d.documentTypeId == job.documentTypeId)
        && (d.clientId.isNull || feedback.get(d.clientId.value, true)))
        docs ~= d;
    ExtractedField[] fields;
    foreach (d; docs)
      fields ~= repos.extractedFields.findByReference(t, "documentId", d.id.value);
    return evaluateTrainingData(docs, fields);
  }

  TrainingJob start(TenantId t, TrainingJobId id, UserId actor) {
    auto job = get(t, id);
    auto schema = schemaOf(t, job.schemaId);
    if (schema.isDraft)
      throw DaiException.ruleViolation("Schema '" ~ schema.name ~ "' is a draft — activate it before training");
    foreach (other; repos.trainingJobs.findByReference(t, "schemaId", job.schemaId.value))
      if (other.id != job.id && other.status == TrainingJobStatus.running)
        throw DaiException.ruleViolation("Training job '" ~ other.name ~ "' of schema '" ~ schema.name ~ "' is already running");
    auto data = dataOf(t, job);
    if (data.documents < policy.minTrainingDocuments)
      throw DaiException.ruleViolation(format("Training needs at least %d confirmed documents of schema '%s' (found %d)",
          policy.minTrainingDocuments, schema.name, data.documents));
    job.start(data.documents, data.fields, now);
    stampUpdated(job, actor, now);
    repos.trainingJobs.save(job);
    emit("training.started", t, id.value, Json(["documents": Json(data.documents)]));
    if (policy.trainingSeconds <= 0)
      return finish(t, job, actor);
    return job;
  }

  TrainingJob cancel(TenantId t, TrainingJobId id, UserId actor) {
    auto job = get(t, id);
    job.cancel(now);
    stampUpdated(job, actor, now);
    repos.trainingJobs.save(job);
    emit("training.cancelled", t, id.value);
    return job;
  }

  long advance(TenantId t, UserId actor) {
    long completed;
    auto due = plusSeconds(now, -policy.trainingSeconds);
    foreach (job; repos.trainingJobs.findByReference(t, "status", cast(string) TrainingJobStatus.running))
      if (job.startedAt <= due) {
        finish(t, job, actor);
        completed++;
      }
    return completed;
  }

  long durationSeconds() {
    return policy.trainingSeconds;
  }

  protected TrainingJob finish(TenantId t, TrainingJob job, UserId actor) {
    auto data = dataOf(t, job);
    if (data.fields == 0)
      job.fail("No values to train with (the confirmed documents were deleted)", now);
    else {
      long versions = 1;
      foreach (other; repos.trainingJobs.findByReference(t, "schemaId", job.schemaId.value))
        if (other.id != job.id && other.status == TrainingJobStatus.completed)
          versions++;
      job.documentCount = data.documents;
      job.fieldCount = data.fields;
      job.complete(data.accuracy, format("%s-v%d", job.schemaId.value, versions), now);
    }
    stampUpdated(job, actor, now);
    repos.trainingJobs.save(job);
    emit(job.status == TrainingJobStatus.completed ? "training.completed" : "training.failed", t, job.id.value,
      Json(["accuracy": Json(job.accuracy)]));
    return job;
  }
}

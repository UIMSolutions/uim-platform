/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.training_job;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct TrainingMetric {
  string name;
  double value;
  long timestamp;
}

struct TrainingJob {
  TrainingJobId id;
  TenantId tenantId;
  ClientId clientId;
  DocumentTypeId documentTypeId;
  SchemaId schemaId;
  string name;
  string description;
  string modelVersion;
  TrainingJobStatus status;
  string statusMessage;
  int documentCount;
  double accuracy;
  TrainingMetric[] metrics;
  long startedAt;
  long completedAt;
  long createdAt;
  long updatedAt;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.training_jobs;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.training_job;
import uim.platform.document_ai.domain.ports.repositories.training_jobs;
import uim.platform.document_ai.domain.ports.repositories.documents;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageTrainingJobsUseCase { // TODO: UIMUseCase {
  private TrainingJobRepository jobRepo;
  private DocumentRepository docRepo;

  this(TrainingJobRepository jobRepo, DocumentRepository docRepo) {
    this.jobRepo = jobRepo;
    this.docRepo = docRepo;
  }

  CommandResult create(CreateTrainingJobRequest r) {
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");
    if (r.documentTypeId.isEmpty)
      return CommandResult(false, "", "Document type ID is required");

    // Count confirmed documents available for training
    auto docs = docRepo.findByDocumentType(r.documentTypeId, r.clientId);
    int confirmedCount = 0;
    foreach (d; docs) {
      if (d.status == DocumentStatus.confirmed)
        confirmedCount++;
    }

    TrainingJob tj;
    tj.id = randomUUID();
    tj.tenantId = r.tenantId;
    tj.clientId = r.clientId;
    tj.documentTypeId = r.documentTypeId;
    tj.schemaId = r.schemaId;
    tj.name = r.name.length > 0 ? r.name : "Training Job";
    tj.description = r.description;
    tj.modelVersion = "1.0";
    tj.status = TrainingJobStatus.pending;
    tj.documentCount = confirmedCount;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    tj.createdAt = now;
    tj.updatedAt = now;

    jobRepo.save(tj);
    return CommandResult(true, tj.id, "");
  }

  CommandResult patch(PatchTrainingJobRequest r) {
    if (r.trainingJobId.isEmpty)
      return CommandResult(false, "", "Training job ID is required");

    auto existing = jobRepo.findById(r.trainingJobId, r.clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Training job not found");

    if (r.targetStatus.length > 0) {
      switch (r.targetStatus) {
        case "running":
          if (existing.status != TrainingJobStatus.pending)
            return CommandResult(false, "", "Can only start pending jobs");
          existing.status = TrainingJobStatus.running;
          import core.time : MonoTime;
          existing.startedAt = MonoTime.currTime.ticks;
          break;
        case "cancelled":
          if (existing.status != TrainingJobStatus.pending && existing.status != TrainingJobStatus.running)
            return CommandResult(false, "", "Can only cancel pending or running jobs");
          existing.status = TrainingJobStatus.cancelled;
          break;
        default:
          return CommandResult(false, "", "Invalid target status");
      }
    }

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    jobRepo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  TrainingJob getById(TrainingJobId id, ClientId clientId) {
    return jobRepo.findById(id, clientId);
  }

  TrainingJob[] list(ClientId clientId) {
    return jobRepo.findByClient(clientId);
  }

  TrainingJob[] listByStatus(TrainingJobStatus status, ClientId clientId) {
    return jobRepo.findByStatus(status, clientId);
  }

  TrainingJob[] listByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    return jobRepo.findByDocumentType(typeId, clientId);
  }

  CommandResult remove(TrainingJobId id, ClientId clientId) {
    auto existing = jobRepo.findById(id, clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Training job not found");
    if (existing.status == TrainingJobStatus.running)
      return CommandResult(false, "", "Cannot delete running training job");

    jobRepo.remove(id, clientId);
    return CommandResult(true, id.value, "");
  }

  size_t count(ClientId clientId) {
    return jobRepo.countByClient(clientId);
  }
}

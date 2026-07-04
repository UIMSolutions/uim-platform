/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.training_jobs;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.training_job;
// import uim.platform.document_ai.domain.ports.repositories.training_jobs;
// import uim.platform.document_ai.domain.ports.repositories.documents;
// import uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageTrainingJobsUseCase { // TODO: UIMUseCase {
  private TrainingJobRepository jobRepo;
  private DocumentRepository docRepo;

  this(TrainingJobRepository jobRepo, DocumentRepository docRepo) {
    this.jobRepo = jobRepo;
    this.docRepo = docRepo;
  }

  CommandResult createTrainingJob(CreateTrainingJobRequest r) {
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");
    if (r.documentTypeId.isEmpty)
      return CommandResult(false, "", "Document type ID is required");

    // Count confirmed documents available for training
    auto docs = docRepo.findByDocumentType(r.clientId, r.documentTypeId);
    int confirmedCount = 0;
    foreach (d; docs) {
      if (d.status == DocumentStatus.confirmed)
        confirmedCount++;
    }

    auto tj = TrainingJob(r.tenantId);
    tj.clientId = r.clientId;
    tj.documentTypeId = r.documentTypeId;
    tj.schemaId = r.schemaId;
    tj.name = r.name.length > 0 ? r.name : "Training Job";
    tj.description = r.description;
    tj.modelVersion = "1.0";
    tj.status = TrainingJobStatus.pending;
    tj.documentCount = confirmedCount;

    jobRepo.save(tj);
    return CommandResult(true, tj.id.value, "");
  }

  CommandResult patchTrainingJob(PatchTrainingJobRequest r) {
    if (r.trainingJobId.isEmpty)
      return CommandResult(false, "", "Training job ID is required");

    auto existing = jobRepo.findById(r.clientId, r.trainingJobId);
    if (existing.isNull)
      return CommandResult(false, "", "Training job not found");

    if (r.targetStatus.length > 0) {
      switch (r.targetStatus) {
        case "running":
          if (existing.status != TrainingJobStatus.pending)
            return CommandResult(false, "", "Can only start pending jobs");
          existing.status = TrainingJobStatus.running;
          
          existing.startedAt = currentTimestamp;
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

    
    existing.updatedAt = currentTimestamp;

    jobRepo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  TrainingJob getTrainingJob(ClientId clientId, TrainingJobId id) {
    return jobRepo.findById(clientId, id);
  }

  TrainingJob[] listTrainingJobs(ClientId clientId) {
    return jobRepo.findByClient(clientId);
  }

  TrainingJob[] listTrainingJobs(ClientId clientId, TrainingJobStatus status) {
    return jobRepo.findByStatus(clientId, status);
  }

  TrainingJob[] listTrainingJobs(ClientId clientId, DocumentTypeId typeId) {
    return jobRepo.findByDocumentType(clientId, typeId);
  }

  CommandResult deleteTrainingJob(ClientId clientId, TrainingJobId id) {
    auto job = jobRepo.findById(clientId, id);
    if (job.isNull)
      return CommandResult(false, "", "Training job not found");

    if (job.status == TrainingJobStatus.running)
      return CommandResult(false, "", "Cannot delete running training job");

    jobRepo.remove(job);
    return CommandResult(true, job.id.value, "");
  }

  size_t countTrainingJobs(ClientId clientId) {
    return jobRepo.countByClient(clientId);
  }
}

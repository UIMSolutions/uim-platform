/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.training_jobs;

// import uim.platform.document_ai.domain.entities.training_job;
// import uim.platform.document_ai.domain.ports.repositories.training_jobs;
// import uim.platform.document_ai.domain.ports.repositories.documents;
// import uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageTrainingJobsUseCase {
  protected TrainingJobRepository jobRepo;
  private DocumentRepository docRepo;

  this(TrainingJobRepository jobRepo, DocumentRepository docRepo) {
    this.jobRepo = jobRepo;
    this.docRepo = docRepo;
  }

  UsecaseResult createTrainingJob(CreateTrainingJobRequest r) {
    if (r.clientId.isEmpty)
      return UsecaseResult(false, "", "Client ID is required");
    if (r.documentTypeId.isEmpty)
      return UsecaseResult(false, "", "AiDocument type ID is required");

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
    return UsecaseResult(true, tj.id.value, "");
  }

  UsecaseResult patchTrainingJob(PatchTrainingJobRequest r) {
    if (r.trainingJobId.isEmpty)
      return UsecaseResult(false, "", "Training job ID is required");

    auto existing = jobRepo.findById(r.tenantId, r.clientId, r.trainingJobId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Training job not found");

    if (r.targetStatus.length > 0) {
      switch (r.targetStatus) {
        case "running":
          if (existing.status != TrainingJobStatus.pending)
            return UsecaseResult(false, "", "Can only start pending jobs");
          existing.status = TrainingJobStatus.running;
          
          existing.startedAt = currentTimestamp;
          break;
        case "cancelled":
          if (existing.status != TrainingJobStatus.pending && existing.status != TrainingJobStatus.running)
            return UsecaseResult(false, "", "Can only cancel pending or running jobs");
          existing.status = TrainingJobStatus.cancelled;
          break;
        default:
          return UsecaseResult(false, "", "Invalid target status");
      }
    }

    
    existing.updatedAt = currentTimestamp;

    jobRepo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  TrainingJob getTrainingJob(TenantId tenantId, ClientId clientId, TrainingJobId id) {
    return jobRepo.findById(tenantId, clientId, id);
  }

  TrainingJob[] listTrainingJobs(TenantId tenantId, ClientId clientId) {
    return jobRepo.findByClient(tenantId, clientId);
  }

  TrainingJob[] listTrainingJobs(TenantId tenantId, ClientId clientId, TrainingJobStatus status) {
    return jobRepo.findByStatus(tenantId, clientId, status);
  }

  TrainingJob[] listTrainingJobs(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return jobRepo.findByDocumentType(tenantId, clientId, typeId);
  }

  UsecaseResult deleteTrainingJob(TenantId tenantId, ClientId clientId, TrainingJobId id) {
    auto job = jobRepo.findById(tenantId, clientId, id);
    if (job.isNull)
      return UsecaseResult(false, "", "Training job not found");

    if (job.status == TrainingJobStatus.running)
      return UsecaseResult(false, "", "Cannot delete running training job");

    jobRepo.remove(job);
    return UsecaseResult(true, job.id.value, "");
  }

  size_t countTrainingJobs(TenantId tenantId, ClientId clientId) {
    return jobRepo.countByClient(tenantId, clientId);
  }
}

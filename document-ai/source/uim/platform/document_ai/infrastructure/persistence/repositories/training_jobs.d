/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.training_jobs;

// import uim.platform.document_ai.domain.entities.training_job;
// import uim.platform.document_ai.domain.ports.repositories.training_jobs;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class TrainingJobRepository : TenantRepository!(TrainingJob, TrainingJobId), ITrainingJobRepository {

  bool existsById(TenantId tenantId, ClientId clientId, TrainingJobId id) {
    return findByClient(tenantId, clientId).any!(tj => tj.id == id);
  }

  TrainingJob findById(TenantId tenantId, ClientId clientId, TrainingJobId id) {
    foreach (tj; findByClient(tenantId, clientId)) {
      if (tj.id == id)
        return tj;
    }
    return TrainingJob.init;
  }

  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  TrainingJob[] filterByClient(TrainingJob[] trainingJobs, ClientId clientId) {
    return trainingJobs.filter!(tj => tj.clientId == clientId).array;
  }

  TrainingJob[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByTenant(tenantId), clientId);
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(tj => remove(tj));
  }

  size_t countByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return findByDocumentType(tenantId, clientId, typeId).length;
  }

  TrainingJob[] filterByDocumentType(TrainingJob[] trainingJobs, DocumentTypeId typeId) {
    return trainingJobs.filter!(tj => tj.documentTypeId == typeId).array;
  }

  TrainingJob[] findByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return filterByDocumentType(filterByClient(findByTenant(tenantId), clientId), typeId);
  }

  void removeByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    findByDocumentType(tenantId, clientId, typeId).each!(tj => remove(tj));
  }

  size_t countByStatus(TenantId tenantId, ClientId clientId, TrainingJobStatus status) {
    return findByStatus(tenantId, clientId, status).length;
  }

  TrainingJob[] filterByStatus(TrainingJob[] trainingJobs, TrainingJobStatus status) {
    return trainingJobs.filter!(tj => tj.status == status).array;
  }

  TrainingJob[] findByStatus(TenantId tenantId, ClientId clientId, TrainingJobStatus status) {
    return filterByStatus(findByClient(tenantId, clientId), status);
  }

  void removeByStatus(TenantId tenantId, ClientId clientId, TrainingJobStatus status) {
    findByStatus(tenantId, clientId, status).each!(tj => remove(tj));
  }

}

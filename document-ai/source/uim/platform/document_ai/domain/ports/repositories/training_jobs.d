/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.training_jobs;

// import uim.platform.document_ai.domain.entities.training_job;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface ITrainingJobRepository : ITenantRepository!(TrainingJob, TrainingJobId) {
  
  size_t countByClient(TenantId tenantId, ClientId clientId);
  TrainingJob[] findByClient(TenantId tenantId, ClientId clientId);
  void removeByClient(TenantId tenantId, ClientId clientId);

  size_t countByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId);
  TrainingJob[] findByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId);
  void removeByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId);

  size_t countByStatus(TenantId tenantId, ClientId clientId, TrainingJobStatus status);
  TrainingJob[] findByStatus(TenantId tenantId, ClientId clientId, TrainingJobStatus status);
  void removeByStatus(TenantId tenantId, ClientId clientId, TrainingJobStatus status);

}

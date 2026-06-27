/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.training_jobs;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.training_job;
import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:
interface TrainingJobRepository : ITenantRepository!(TrainingJob, TrainingJobId) {
  
  bool existsById(TenantId tenantId, TrainingJobId id, ClientId clientId);
  TrainingJob findById(TenantId tenantId, TrainingJobId id, ClientId clientId);
  void removeById(TenantId tenantId, TrainingJobId id, ClientId clientId);

  size_t countByClient(TenantId tenantId, ClientId clientId);
  TrainingJob[] findByClient(TenantId tenantId, ClientId clientId);
  void removeByClient(TenantId tenantId, ClientId clientId);

  size_t countByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId);
  TrainingJob[] findByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId);
  void removeByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId);

  size_t countByStatus(TenantId tenantId, TrainingJobStatus status, ClientId clientId);
  TrainingJob[] findByStatus(TenantId tenantId, TrainingJobStatus status, ClientId clientId);
  void removeByStatus(TenantId tenantId, TrainingJobStatus status, ClientId clientId);

}

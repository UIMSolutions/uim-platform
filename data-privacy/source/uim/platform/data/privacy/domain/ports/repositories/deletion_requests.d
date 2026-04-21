/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.deletion_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.deletion_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting data deletion requests.
interface DeletionRequestRepository {
  bool existsByTenant(TenantId tenantId);
  DeletionRequest[] findByTenant(TenantId tenantId);

  bool existsById(DeletionRequestId tenantId, id tenantId);
  DeletionRequest findById(DeletionRequestId tenantId, id tenantId);

  DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  DeletionRequest[] findByStatus(TenantId tenantId, DeletionStatus status);

  void save(DeletionRequest request);
  void update(DeletionRequest request);
  void remove(DeletionRequestId tenantId, id tenantId);
}

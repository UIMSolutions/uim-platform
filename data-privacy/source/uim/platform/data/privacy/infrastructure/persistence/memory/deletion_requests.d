/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.deletion_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.deletion_request;
// import uim.platform.data.privacy.domain.ports.repositories.deletion_requests;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDeletionRequestRepository : DeletionRequestRepository {
  private DeletionRequest[] store;

  DeletionRequest[] findByTenant(TenantId tenantId) {
    DeletionRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId)
        result ~= r;
    return result;
  }

  DeletionRequest* findById(DeletionRequestId id, TenantId tenantId) {
    foreach (ref r; store)
      if (r.id == id && r.tenantId == tenantId)
        return &r;
    return null;
  }

  DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    DeletionRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.dataSubjectId == dataSubjectId)
        result ~= r;
    return result;
  }

  DeletionRequest[] findByStatus(TenantId tenantId, DeletionStatus status) {
    DeletionRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.status == status)
        result ~= r;
    return result;
  }

  void save(DeletionRequest request) {
    store ~= request;
  }

  void update(DeletionRequest request) {
    foreach (ref r; store)
      if (r.id == request.id && r.tenantId == request.tenantId) {
        r = request;
        return;
      }
  }

  void remove(DeletionRequestId id, TenantId tenantId) {
    DeletionRequest[] kept;
    foreach (ref r; findByTenant(tenantId))
      if (!(r.id == id))
        kept ~= r;
    store = kept;
  }
}

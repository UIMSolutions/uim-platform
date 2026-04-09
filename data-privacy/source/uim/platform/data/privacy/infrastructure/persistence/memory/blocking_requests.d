/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.blocking_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.blocking_request;
// import uim.platform.data.privacy.domain.ports.repositories.blocking_requests;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryBlockingRequestRepository : BlockingRequestRepository {
  private BlockingRequest[] store;

  BlockingRequest[] findByTenant(TenantId tenantId) {
    BlockingRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId)
        result ~= r;
    return result;
  }

  BlockingRequest* findById(BlockingRequestId tenantId, id tenantId) {
    foreach (ref r; store)
      if (r.id == id && r.tenantId == tenantId)
        return &r;
    return null;
  }

  BlockingRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    BlockingRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.dataSubjectId == dataSubjectId)
        result ~= r;
    return result;
  }

  BlockingRequest[] findByStatus(TenantId tenantId, BlockingStatus status) {
    BlockingRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.status == status)
        result ~= r;
    return result;
  }

  void save(BlockingRequest request) {
    store ~= request;
  }

  void update(BlockingRequest request) {
    foreach (ref r; store)
      if (r.id == request.id && r.tenantId == request.tenantId) {
        r = request;
        return;
      }
  }

  void remove(BlockingRequestId tenantId, id tenantId) {
    BlockingRequest[] kept;
    foreach (ref r; store)
      if (!(r.id == id && r.tenantId == tenantId))
        kept ~= r;
    store = kept;
  }
}

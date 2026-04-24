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
class MemoryBlockingRequestRepository : TenantRepository!(BlockingRequest, BlockingRequestId), BlockingRequestRepository {

  // #region ByDataSubject
  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findByDataSubject(tenantId, dataSubjectId).length;
  }

  BlockingRequest[] filterByDataSubject(BlockingRequest[] requests, DataSubjectId dataSubjectId) {
    return requests.filter!(r => r.dataSubjectId == dataSubjectId).array;
  }

  BlockingRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    findByDataSubject(tenantId, dataSubjectId).each!(entity => remove(entity));
  }
  // #endregion ByDataSubject

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, BlockingStatus status) {
    return findByStatus(tenantId, status).length;
  }

  BlockingRequest[] filterByStatus(BlockingRequest[] requests, BlockingStatus status) {
    return requests.filter!(r => r.status == status).array;
  }

  BlockingRequest[] findByStatus(TenantId tenantId, BlockingStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, BlockingStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }
  // #endregion ByStatus
  
}

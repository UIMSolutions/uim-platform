/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.data_retrieval_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_retrieval_request;
// import uim.platform.data.privacy.domain.ports.repositories.data_retrieval_requests;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDataRetrievalRequestRepository : TenantRepository!(DataRetrievalRequest, DataRetrievalRequestId), DataRetrievalRequestRepository {

  // #region ByDataSubject
  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findByDataSubject(tenantId, dataSubjectId).length;
  }

  DataRetrievalRequest[] filterByDataSubject(DataRetrievalRequest[] requests, DataSubjectId dataSubjectId) {
    return requests.filter!(r => r.dataSubjectId == dataSubjectId).array;
  }

  DataRetrievalRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    findByDataSubject(tenantId, dataSubjectId).each!(entity => remove(entity.id));
  }
  // #endregion ByDataSubject

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, RetrievalStatus status) {
    return findByStatus(tenantId, status).length;
  }

  DataRetrievalRequest[] filterByStatus(DataRetrievalRequest[] requests, RetrievalStatus status) {
    return requests.filter!(r => r.status == status).array;
  }

  DataRetrievalRequest[] findByStatus(TenantId tenantId, RetrievalStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, RetrievalStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity.id));
  }
  // #endregion ByStatus

}

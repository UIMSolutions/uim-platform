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
class MemoryDataRetrievalRequestRepository : DataRetrievalRequestRepository {
  private DataRetrievalRequest[] store;

  DataRetrievalRequest[] findByTenant(TenantId tenantId) {
    DataRetrievalRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId)
        result ~= r;
    return result;
  }

  DataRetrievalRequest* findById(DataRetrievalRequestId tenantId, id tenantId) {
    foreach (ref r; store)
      if (r.id == id && r.tenantId == tenantId)
        return &r;
    return null;
  }

  DataRetrievalRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    DataRetrievalRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.dataSubjectId == dataSubjectId)
        result ~= r;
    return result;
  }

  DataRetrievalRequest[] findByStatus(TenantId tenantId, RetrievalStatus status) {
    DataRetrievalRequest[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.status == status)
        result ~= r;
    return result;
  }

  void save(DataRetrievalRequest request) {
    store ~= request;
  }

  void update(DataRetrievalRequest request) {
    foreach (ref r; store)
      if (r.id == request.id && r.tenantId == request.tenantId) {
        r = request;
        return;
      }
  }

  void remove(DataRetrievalRequestId tenantId, id tenantId) {
    DataRetrievalRequest[] kept;
    foreach (ref r; findByTenant(tenantId))
      if (!(r.id == id))
        kept ~= r;
    store = kept;
  }
}

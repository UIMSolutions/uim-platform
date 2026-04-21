/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.data_retrieval_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_retrieval_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting data subject access / retrieval requests.
interface DataRetrievalRequestRepository : ITenantRepository!(DataRetrievalRequest, DataRetrievalRequestId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  DataRetrievalRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByStatus(TenantId tenantId, RetrievalStatus status);
  DataRetrievalRequest[] findByStatus(TenantId tenantId, RetrievalStatus status);
  void removeByStatus(TenantId tenantId, RetrievalStatus status);

}

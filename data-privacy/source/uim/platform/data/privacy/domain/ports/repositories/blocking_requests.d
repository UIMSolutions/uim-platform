/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.blocking_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.blocking_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting data blocking / restriction requests.
interface BlockingRequestRepository : ITenantRepository!(BlockingRequest, BlockingRequestId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  BlockingRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByStatus(TenantId tenantId, BlockingStatus status);
  BlockingRequest[] findByStatus(TenantId tenantId, BlockingStatus status);
  void removeByStatus(TenantId tenantId, BlockingStatus status);

}

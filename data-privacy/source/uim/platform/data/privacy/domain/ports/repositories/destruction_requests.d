/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.destruction_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.destruction_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying destruction requests.
interface DestructionRequestRepository : ITenantRepository!(DestructionRequest, DestructionRequestId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  DestructionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByStatus(TenantId tenantId, DestructionStatus status);
  DestructionRequest[] findByStatus(TenantId tenantId, DestructionStatus status);
  void removeByStatus(TenantId tenantId, DestructionStatus status);

}

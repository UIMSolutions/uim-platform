/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.correction_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.correction_request;
// import uim.platform.data.privacy.domain.ports.correction_request_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryCorrectionRequestRepository : TenantRepository!(CorrectionRequest, CorrectionRequestId), CorrectionRequestRepository {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return findByDataSubject(tenantId, subjectId).length;
  }

  CorrectionRequest[] filterByDataSubject(CorrectionRequest[] requests, DataSubjectId subjectId) {
    return requests.filter!(r => r.dataSubjectId == subjectId).array;
  }

  CorrectionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return filterByDataSubject(findByTenant(tenantId), subjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    findByDataSubject(tenantId, subjectId).each!(entity => remove(entity));
  }

  size_t countByStatus(TenantId tenantId, CorrectionStatus status) {
    return findByStatus(tenantId, status).length;
  }

  CorrectionRequest[] filterByStatus(CorrectionRequest[] requests, CorrectionStatus status) {
    return requests.filter!(r => r.status == status).array;
  }

  CorrectionRequest[] findByStatus(TenantId tenantId, CorrectionStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, CorrectionStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }

}

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
class MemoryCorrectionRequestRepository : CorrectionRequestRepository {
  private CorrectionRequest[] store;

  CorrectionRequest[] findByTenant(TenantId tenantId) {
    CorrectionRequest[] result;
    foreach (s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  CorrectionRequest* findById(CorrectionRequestId tenantId, id tenantId) {
    foreach (s; findByTenant(tenantId))
      if (s.id == id)
        return &s;
    return null;
  }

  CorrectionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    CorrectionRequest[] result;
    foreach (s; findByTenant(tenantId))
      if (s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  CorrectionRequest[] findByStatus(TenantId tenantId, CorrectionStatus status) {
    CorrectionRequest[] result;
    foreach (s; findByTenant(tenantId))
      if (s.status == status)
        result ~= s;
    return result;
  }

  void save(CorrectionRequest entity) {
    store ~= entity;
  }

  void update(CorrectionRequest entity) {
    foreach (s; findByTenant(entity.tenantId))
      if (s.id == entity.id) {
        s = entity;
        return;
      }
  }

  void remove(CorrectionRequestId tenantId, id tenantId) {
    CorrectionRequest[] kept;
    foreach (s; findByTenant(tenantId))
      if (!(s.id == id))
        kept ~= s;
    store = kept;
  }
}

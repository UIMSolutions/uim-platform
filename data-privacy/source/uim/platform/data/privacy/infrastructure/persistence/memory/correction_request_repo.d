/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.correction_request_repo;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.correction_request;
import uim.platform.data.privacy.domain.ports.correction_request_repository;

class MemoryCorrectionRequestRepository : CorrectionRequestRepository {
  private CorrectionRequest[] store;

  CorrectionRequest[] findByTenant(TenantId tenantId) {
    CorrectionRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  CorrectionRequest* findById(CorrectionRequestId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  CorrectionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    CorrectionRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  CorrectionRequest[] findByStatus(TenantId tenantId, CorrectionStatus status) {
    CorrectionRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(CorrectionRequest entity) {
    store ~= entity;
  }

  void update(CorrectionRequest entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(CorrectionRequestId id, TenantId tenantId) {
    CorrectionRequest[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}

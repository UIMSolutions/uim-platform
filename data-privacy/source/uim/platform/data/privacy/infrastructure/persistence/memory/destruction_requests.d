/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.destruction_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.destruction_request;
// import uim.platform.data.privacy.domain.ports.repositories.destruction_requests;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDestructionRequestRepository : DestructionRequestRepository {
  private DestructionRequest[] store;

  DestructionRequest[] findByTenant(TenantId tenantId) {
    DestructionRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  DestructionRequest* findById(DestructionRequestId tenantId, id tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  DestructionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    DestructionRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  DestructionRequest[] findByStatus(TenantId tenantId, DestructionStatus status) {
    DestructionRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(DestructionRequest entity) {
    store ~= entity;
  }

  void update(DestructionRequest entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(DestructionRequestId tenantId, id tenantId) {
    DestructionRequest[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}

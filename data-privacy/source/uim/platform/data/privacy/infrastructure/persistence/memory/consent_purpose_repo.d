/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.consent_purpose_repo;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.consent_purpose;
import uim.platform.data.privacy.domain.ports.consent_purpose_repository;

class MemoryConsentPurposeRepository : ConsentPurposeRepository {
  private ConsentPurpose[] store;

  ConsentPurpose[] findByTenant(TenantId tenantId) {
    ConsentPurpose[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  ConsentPurpose* findById(ConsentPurposeId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  ConsentPurpose[] findByController(TenantId tenantId, DataControllerId controllerId) {
    ConsentPurpose[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.controllerId == controllerId)
        result ~= s;
    return result;
  }

  ConsentPurpose[] findByStatus(TenantId tenantId, ConsentPurposeStatus status) {
    ConsentPurpose[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(ConsentPurpose entity) {
    store ~= entity;
  }

  void update(ConsentPurpose entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(ConsentPurposeId id, TenantId tenantId) {
    ConsentPurpose[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}

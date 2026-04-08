/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.consent_purposes;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_purpose;
// import uim.platform.data.privacy.domain.ports.consent_purpose_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryConsentPurposeRepository : ConsentPurposeRepository {
  private ConsentPurpose[ConsentPurposeId][TenantId] store;

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store;
  }

  ConsentPurpose[] findByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return null;

    return store[tenantId].byValue.array;
  }

  bool existsById(ConsentPurposeId id, TenantId tenantId) {
    return (existsByTenant(tenantId) && (id in store[tenantId]));
  }

  ConsentPurpose findById(ConsentPurposeId id, TenantId tenantId) {
    return existsById(id, tenantId) ? store[tenantId][id] : ConsentPurpose.init;
  }

  ConsentPurpose[] findByController(TenantId tenantId, DataControllerId controllerId) {
    if (!existsByTenant(tenantId))
      return null;

    ConsentPurpose[] result;
    foreach (ref s; store[tenantId].byValue)
      if (s.controllerId == controllerId)
        result ~= s;
    return result;
  }

  ConsentPurpose[] findByStatus(TenantId tenantId, ConsentPurposeStatus status) {
    if (!existsByTenant(tenantId))
      return null;

    ConsentPurpose[] result;
    foreach (ref s; store[tenantId].byValue)
      if (s.status == status)
        result ~= s;
    return result;
  }

  void save(ConsentPurpose entity) {
    if (!existsByTenant(entity.tenantId)) {
      ConsentPurpose[ConsentPurposeId] purposes;
      store[entity.tenantId] = purposes;
    }
    store[entity.tenantId][entity.id] = entity;
  }

  void update(ConsentPurpose entity) {
    if (!existsById(entity.id, entity.tenantId))
      return;

    store[entity.tenantId][entity.id] = entity;
  }

  void remove(ConsentPurposeId id, TenantId tenantId) {
    if (!existsById(id, tenantId))
      return;

    store[tenantId].remove(id);
    if (store[tenantId].empty) {
      store.remove(tenantId);
    }
  }
}

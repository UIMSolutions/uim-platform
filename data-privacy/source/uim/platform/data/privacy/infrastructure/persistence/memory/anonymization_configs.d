/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.anonymization_configs;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.anonymization_config;
// import uim.platform.data.privacy.domain.ports.anonymization_config_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryAnonymizationConfigRepository : AnonymizationConfigRepository {
  private AnonymizationConfig[AnonymizationConfigId][TenantId] store;

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store;
  }

  AnonymizationConfig[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(s => s.tenantId == tenantId).array;
  }

  bool existsById(AnonymizationConfigId tenantId, id tenantId) {
    return (existsByTenant(tenantId) && (id in store[tenantId]));
  }

  AnonymizationConfig findById(AnonymizationConfigId tenantId, id tenantId) {
    if (!existsById(tenantId, id))
      return AnonymizationConfig.init;

    return store[tenantId][id];
  }

  AnonymizationConfig[] findByStatus(TenantId tenantId, AnonymizationConfigStatus status) {
    return findByTenant(tenantId).filter!(config => config.status == status).array;
  }

  void save(AnonymizationConfig entity) {
    if (!existsByTenant(entity.tenantId)) {
      AnonymizationConfig[AnonymizationConfigId] configs;
      store[entity.tenantId] = configs;
    }
    store[entity.tenantId][entity.id] = entity;
  }

  void update(AnonymizationConfig entity) {
    if (existsById(entity.id, entity.tenantId)) {
      store[entity.tenantId][entity.id] = entity;
    }
  }

  void remove(AnonymizationConfigId tenantId, id tenantId) {
    if (existsById(tenantId, id)) {
      store[tenantId].remove(id);
      if (store[tenantId].empty) {
        store.remove(tenantId);
      }
    }
  }
}

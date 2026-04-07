/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.anonymization_configs;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.anonymization_config;
import uim.platform.data.privacy.domain.ports.anonymization_config_repository;

class MemoryAnonymizationConfigRepository : AnonymizationConfigRepository {
  private AnonymizationConfig[] store;

  AnonymizationConfig[] findByTenant(TenantId tenantId) {
    AnonymizationConfig[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  AnonymizationConfig* findById(AnonymizationConfigId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  AnonymizationConfig[] findByStatus(TenantId tenantId, AnonymizationConfigStatus status) {
    AnonymizationConfig[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(AnonymizationConfig entity) {
    store ~= entity;
  }

  void update(AnonymizationConfig entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(AnonymizationConfigId id, TenantId tenantId) {
    AnonymizationConfig[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}

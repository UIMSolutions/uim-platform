/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.configurations;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.configuration;
// import uim.platform.hana.domain.ports.repositories.configurations;
// 
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : ConfigurationRepository {
  private Configuration[] store;

  Configuration findById(ConfigurationId id) {
    foreach (c; store) {
      if (c.id == id)
        return c;
    }
    return Configuration.init;
  }

  Configuration[] findByTenant(TenantId tenantId) {
    return store.filter!(c => c.tenantId == tenantId).array;
  }

  Configuration[] findByInstance(InstanceId instanceId) {
    return store.filter!(c => c.instanceId == instanceId).array;
  }

  Configuration[] findBySection(InstanceId instanceId, string section) {
    return store.filter!(c => c.instanceId == instanceId && c.section == section).array;
  }

  void save(Configuration c) {
    store ~= c;
  }

  void update(Configuration c) {
    foreach (existing; store) {
      if (existing.id == c.id) {
        existing = c;
        return;
      }
    }
  }

  void remove(ConfigurationId id) {
    store = store.filter!(c => c.id != id).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.filter!(c => c.tenantId == tenantId).array.length;
  }
}

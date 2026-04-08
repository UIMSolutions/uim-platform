/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.audit_config;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_config;
// import uim.platform.auditlog.domain.ports.repositories.audit_configs;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryAuditConfigRepository : AuditConfigRepository {
  private AuditConfig[AuditConfigId] store;

  AuditConfig[] findAll() {
    return store.byValue().array;
  }

  bool existsByTenant(TenantId tenantId) {
    return findAll().any!(c => c.tenantId == tenantId);
  }

  AuditConfig findByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return AuditConfig.init;

    foreach (c; findAll())
      if (c.tenantId == tenantId)
        return c;

    return AuditConfig.init;
  }

  bool existsById(AuditConfigId id) {
    return (id in store) ? true : false;
  }

  AuditConfig findById(AuditConfigId id) {
    return existsById(id) ? store[id] : AuditConfig.init;
  }

  void save(AuditConfig config) {
    store[config.id] = config;
  }

  void update(AuditConfig config) {
    store[config.id] = config;
  }

  void remove(TenantId tenantId, AuditConfigId id) {
    if (existsById(id) && store[id].tenantId == tenantId)
      store.remove(id);
  }
}

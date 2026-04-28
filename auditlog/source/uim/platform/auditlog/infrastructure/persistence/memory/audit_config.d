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
class MemoryAuditConfigRepository : TenantRepository!(AuditConfig, AuditConfigId), AuditConfigRepository {
  override AuditConfig[] findAll(size_t offset = 0, size_t limit = 0) {
    return limit == 0 
      ? store.byKeyValue.map!(kv => getByTenant(kv.key)).array.skip(offset)
      : store.byKeyValue.map!(kv => getByTenant(kv.key)).array.skip(offset).take(limit);
  }

  AuditConfig getByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return AuditConfig.init;

    foreach (config; store[tenantId])
        return config;

    return AuditConfig.init;
  }
}


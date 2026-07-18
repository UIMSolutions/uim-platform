/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.repositories.audit_config;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_config;
// import uim.platform.auditlog.domain.ports.repositories.audit_configs;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryAuditConfigRepository : TenantRepository!(AuditConfig, AuditConfigId), AuditConfigRepository {
  // override AuditConfig[] findBy(size_t offset = 0, size_t limit = 0) {
  //   return limit == 0 
  //     ? store.byKeyValue.map!(kv => getByTenant(kv.key)).array.skip(offset)
  //     : store.byKeyValue.map!(kv => getByTenant(kv.key)).array.skip(offset).take(limit);
  // }

  AuditConfig getByTenant(TenantId tenantId) {
    auto configs = findByTenant(tenantId);
    if (configs.length > 0)
      return configs[0];

    return AuditConfig.init;
  }
}


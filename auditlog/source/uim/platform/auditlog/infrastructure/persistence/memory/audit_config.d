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
  AuditConfig[] findAll() {
    AuditConfig[] result;
    foreach (tenantConfigs; findAll())
      result ~= tenantConfigs.byValue().array;
    return result;    
  }

  AuditConfig getByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return AuditConfig.init;

    foreach (c; findAll())
      if (c.tenantId == tenantId)
        return c;

    return AuditConfig.init;
  }
}
///
unittest {
  auto repository = new MemoryAuditConfigRepository();
  auto cfg = AuditConfig();
  cfg.id = "cfg1";
  cfg.tenantId = "tenant1";
  cfg.name = "Test Config";
  repository.save(cfg);

  assert(repository.existsByTenant(TenantId("tenant1")));
  assert(repository.getByTenant(TenantId("tenant1")).id.toString == "cfg1");
  assert(repository.existsById(TenantId("tenant1"), AuditConfigId("cfg1")));
  assert(repository.findById(TenantId("tenant1"), AuditConfigId("cfg1")).name == "Test Config");

  cfg.name = "Updated Config";
  repository.update(cfg);
  assert(repository.findById(TenantId("tenant1"), AuditConfigId("cfg1")).name == "Updated Config");

  repository.remove(TenantId("tenant1"), AuditConfigId("cfg1"));
  assert(!repository.existsById(TenantId("tenant1"), AuditConfigId("cfg1")));
} 

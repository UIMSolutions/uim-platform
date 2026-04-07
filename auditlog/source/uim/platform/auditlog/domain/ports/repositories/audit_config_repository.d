/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.audit_configs;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_config;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Port for persisting tenant-level audit configurations.
@safe:
interface AuditConfigRepository {
  AuditConfig[] findAll();

  bool existsByTenant(TenantId tenantId);
  AuditConfig findByTenant(TenantId tenantId);

  bool existsById(AuditConfigId id);
  AuditConfig findById(AuditConfigId id);

  void save(AuditConfig config);
  void update(AuditConfig config);
  void remove(AuditConfigId id, TenantId tenantId);
}

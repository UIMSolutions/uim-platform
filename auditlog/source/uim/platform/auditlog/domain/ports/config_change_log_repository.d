/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.config_change_logs;

// import uim.platform.auditlog.domain.types;
// 
// import uim.platform.auditlog;import uim.platform.auditlog.domain.entities.config_change_log;

import uim.platform.auditlog;

mixin(ShowModule!());

mixin(ShowModule!());
/// Port for persisting configuration change log records.
@safe:
interface ConfigChangeLogRepository
{
  bool existsByAuditLogId(AuditLogId auditLogId, TenantId tenantId);
  ConfigChangeLog findByAuditLogId(AuditLogId auditLogId, TenantId tenantId);

  ConfigChangeLog[] findByTenant(TenantId tenantId);
  ConfigChangeLog[] findByUser(TenantId tenantId, UserId changedBy);
  ConfigChangeLog[] findByConfigType(TenantId tenantId, string configType);
  ConfigChangeLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

  void save(ConfigChangeLog log);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

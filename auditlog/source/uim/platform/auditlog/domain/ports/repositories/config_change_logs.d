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
interface ConfigChangeLogRepository : ITenantRepository!(ConfigChangeLog, ConfigChangeLogId) {
  
  bool existsByAuditLogId(TenantId tenantId, AuditLogId auditLogId);
  ConfigChangeLog findByAuditLogId(TenantId tenantId, AuditLogId auditLogId);
  void findByAuditLogId(TenantId tenantId, AuditLogId auditLogId);
  
  size_t countByUser(TenantId tenantId, UserId changedBy);
  ConfigChangeLog[] findByUser(TenantId tenantId, UserId changedBy);
  void removeByUser(TenantId tenantId, UserId changedBy);
  
  size_t countByConfigType(TenantId tenantId, string configType);
  ConfigChangeLog[] findByConfigType(TenantId tenantId, string configType);
  void removeByConfigType(TenantId tenantId, string configType);
  
  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  ConfigChangeLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.data_access_logs;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.data_access_log;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Port for persisting data access log records.
@safe:
interface DataAccessLogRepository : ITenantRepository!(DataAccessLog, DataAccessLogId) {

  bool existsByAuditLogId(TenantId tenantId, AuditLogId auditLogId);
  DataAccessLog findByAuditLogId(TenantId tenantId, AuditLogId auditLogId);
  void removeByAuditLogId(TenantId tenantId, AuditLogId auditLogId);

  size_t countByAccessor(TenantId tenantId, UserId accessedBy);
  DataAccessLog[] findByAccessor(TenantId tenantId, UserId accessedBy);
  void removeByAccessor(TenantId tenantId, UserId accessedBy);

  size_t countByDataSubject(TenantId tenantId, string dataSubject);
  DataAccessLog[] findByDataSubject(TenantId tenantId, string dataSubject);
  void removeByDataSubject(TenantId tenantId, string dataSubject);

  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  DataAccessLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

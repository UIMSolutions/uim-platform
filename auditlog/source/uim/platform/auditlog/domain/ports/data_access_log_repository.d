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
interface DataAccessLogRepository
{
  DataAccessLog[] findByTenant(TenantId tenantId);

  bool existsByAuditLogId(AuditLogId auditLogId, TenantId tenantId);
  DataAccessLog findByAuditLogId(AuditLogId auditLogId, TenantId tenantId);

  DataAccessLog[] findByAccessor(TenantId tenantId, UserId accessedBy);
  DataAccessLog[] findByDataSubject(TenantId tenantId, string dataSubject);
  DataAccessLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

  void save(DataAccessLog log);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.audit_logs;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Port for persisting and querying audit log entries.
@safe:
interface AuditLogRepository
{
  AuditLogEntry[] findByTenant(TenantId tenantId);

  bool existsById(AuditLogId id, TenantId tenantId);
  AuditLogEntry findById(AuditLogId id, TenantId tenantId);

  AuditLogEntry[] findByCategory(TenantId tenantId, AuditCategory category);
  AuditLogEntry[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  AuditLogEntry[] findByUser(TenantId tenantId, UserId userId);
  AuditLogEntry[] findByService(TenantId tenantId, ServiceId serviceId);
  AuditLogEntry[] findByCorrelation(string correlationId);
  AuditLogEntry[] search(TenantId tenantId, AuditCategory[] categories,
      long timeFrom, long timeTo, int limit, int offset);

  long countByTenant(TenantId tenantId);
  void save(AuditLogEntry entry);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

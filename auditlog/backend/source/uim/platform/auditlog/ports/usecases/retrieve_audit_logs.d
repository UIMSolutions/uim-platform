/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.usecases.retrieve_audit_logs;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Driving port: query audit log entries.
interface IRetrieveAuditLogsUseCase {
  AuditLogEntry[] queryAuditLogs(AuditLogQueryRequest req);
  bool hasAuditLog(TenantId tenantId, AuditLogId id);
  AuditLogEntry getAuditLog(TenantId tenantId, AuditLogId id);
  AuditLogEntry[] listAuditLogs(TenantId tenantId, AuditCategory category);
  AuditLogEntry[] listAuditLogs(TenantId tenantId, UserId userId);
  AuditLogEntry[] listAuditLogs(TenantId tenantId, string correlationId);
  size_t countAuditLogs(TenantId tenantId);
}

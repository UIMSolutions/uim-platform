/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.usecases.browse_audit_records;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Driving port: read access to the enriched detail records
/// (security events, data access logs, configuration change logs).
interface IBrowseAuditRecordsUseCase {
  SecurityEvent[] listSecurityEvents(TenantId tenantId);
  SecurityEvent getSecurityEvent(TenantId tenantId, SecurityEventId id);

  DataAccessLog[] listDataAccessLogs(TenantId tenantId);
  DataAccessLog getDataAccessLog(TenantId tenantId, DataAccessLogId id);

  ConfigChangeLog[] listConfigChangeLogs(TenantId tenantId);
  ConfigChangeLog getConfigChangeLog(TenantId tenantId, ConfigChangeLogId id);
}

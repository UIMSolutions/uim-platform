/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.retrieve.records;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: read access to the enriched detail records.
class BrowseAuditRecordsUseCase : IBrowseAuditRecordsUseCase {
  protected ISecurityEventRepository securityEvents;
  protected IDataAccessLogRepository dataAccessLogs;
  protected IConfigChangeLogRepository configChangeLogs;

  this(ISecurityEventRepository securityEvents, IDataAccessLogRepository dataAccessLogs,
      IConfigChangeLogRepository configChangeLogs) {
    this.securityEvents = securityEvents;
    this.dataAccessLogs = dataAccessLogs;
    this.configChangeLogs = configChangeLogs;
  }

  SecurityEvent[] listSecurityEvents(TenantId tenantId) {
    return newestFirst(securityEvents.findByTenant(tenantId));
  }

  SecurityEvent getSecurityEvent(TenantId tenantId, SecurityEventId id) {
    return securityEvents.findById(tenantId, id);
  }

  DataAccessLog[] listDataAccessLogs(TenantId tenantId) {
    return newestFirst(dataAccessLogs.findByTenant(tenantId));
  }

  DataAccessLog getDataAccessLog(TenantId tenantId, DataAccessLogId id) {
    return dataAccessLogs.findById(tenantId, id);
  }

  ConfigChangeLog[] listConfigChangeLogs(TenantId tenantId) {
    return newestFirst(configChangeLogs.findByTenant(tenantId));
  }

  ConfigChangeLog getConfigChangeLog(TenantId tenantId, ConfigChangeLogId id) {
    return configChangeLogs.findById(tenantId, id);
  }

  private static T[] newestFirst(T)(T[] items) {
    items.sort!((a, b) => a.timestamp > b.timestamp);
    return items;
  }
}

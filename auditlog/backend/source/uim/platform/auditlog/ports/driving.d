/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.driving;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (HTTP, OData, CLI, GUI)
/// depend on this bundle only — never on concrete use cases or repositories.
struct AuditLogPorts {
  IWriteAuditLogUseCase writeAuditLog;
  IRetrieveAuditLogsUseCase retrieveAuditLogs;
  IBrowseAuditRecordsUseCase browseRecords;
  IWriteSecurityEventUseCase writeSecurityEvent;
  IWriteDataAccessLogUseCase writeDataAccessLog;
  IWriteConfigChangeUseCase writeConfigChange;
  IManageRetentionUseCase manageRetention;
  IEnforceRetentionUseCase enforceRetention;
  IManageAuditConfigUseCase manageAuditConfig;
  IManageExportsUseCase manageExports;
  IAuditStatisticsService statistics;
}

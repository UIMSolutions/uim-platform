/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.monitor.connectivity;

// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.ports.repositories.connectivity_logs;
// import uim.platform.connectivity.domain.types;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Summary of connectivity status for a tenant.
struct ConnectivitySummary {
  ulong totalEvents;
  ulong infoCount;
  ulong warningCount;
  ulong errorCount;
  ulong criticalCount;
}

/// Application service for connectivity monitoring and log queries.
class MonitorConnectivityUseCase : UIMUseCase {
  private ConnectivityLogRepository logRepo;

  this(ConnectivityLogRepository logRepo) {
    this.logRepo = logRepo;
  }

  ConnectivityLog[] listLogs(string tenantId) {
    return listLogs(TenantId(tenantId));
  }

  ConnectivityLog[] listLogs(TenantId tenantId) {
    return logRepo.findByTenant(tenantId);
  }

  ConnectivityLog[] listBySeverity(string tenantId, LogSeverity severity) {
    return listBySeverity(TenantId(tenantId), severity);
  }

  ConnectivityLog[] listBySeverity(TenantId tenantId, LogSeverity severity) {
    return logRepo.findBySeverity(tenantId, severity);
  }

  ConnectivityLog[] listBySource(string sourceId) {
    return listBySource(SourceId(sourceId));
  }

  ConnectivityLog[] listBySource(SourceId sourceId) {
    return logRepo.findBySource(sourceId);
  }

  ConnectivitySummary getSummary(string tenantId) {
    return getSummary(TenantId(tenantId));
  }

  ConnectivitySummary getSummary(TenantId tenantId) {
    auto logs = logRepo.findByTenant(tenantId);
    ConnectivitySummary summary;
    summary.totalEvents = logs.length;

    foreach (log; logs) {
      final switch (log.severity) {
      case LogSeverity.info:
        summary.infoCount++;
        break;
      case LogSeverity.warning:
        summary.warningCount++;
        break;
      case LogSeverity.error:
        summary.errorCount++;
        break;
      case LogSeverity.critical:
        summary.criticalCount++;
        break;
      }
    }

    return summary;
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.connectivity_logs;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.ports.repositories.connectivity_logs;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryConnectivityLogRepository : TenantRepository!(ConnectivityLog, ConnectivityLogId), ConnectivityLogRepository {

  // #region BySeverity
  size_t countBySeverity(TenantId tenantId, LogSeverity severity) {
    return findBySeverity(tenantId, severity).length;
  }

  ConnectivityLog[] findBySeverity(TenantId tenantId, LogSeverity severity) {
    return logs.filter!(e => e.tenantId == tenantId && e.severity == severity).array;
  }

  void removeBySeverity(TenantId tenantId, LogSeverity severity) {
    findByTenant(tenantId).filter!(e => e.severity == severity).each!(e => remove(e));
  }
  // #endregion BySeverity

  // #region BySource
  size_t countBySource(TenantId tenantId, string sourceId) {
    return findBySource(tenantId, sourceId).length;
  }

  ConnectivityLog[] findBySource(TenantId tenantId, string sourceId) {
    return findByTenant(tenantId).filter!(e => e.sourceId == sourceId).array;
  }

  void removeBySource(TenantId tenantId, string sourceId) {
    findByTenant(tenantId).filter!(e => e.sourceId == sourceId).each!(e => remove(e));
  }
  // #endregion BySource

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.connectivity_logs;
// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Port: outgoing - connectivity event log persistence.
interface ConnectivityLogRepository : ITenantRepository!(ConnectivityLogEntry, ConnectivityLogEntryId) {

  size_t countBySeverity(TenantId tenantId, LogSeverity severity);
  ConnectivityLogEntry[] findBySeverity(TenantId tenantId, LogSeverity severity);
  void removeBySeverity(TenantId tenantId, LogSeverity severity);

  size_t countBySource(TenantId tenantId, string sourceId);
  ConnectivityLogEntry[] findBySource(TenantId tenantId, string sourceId);
  void removeBySource(TenantId tenantId, string sourceId);

}

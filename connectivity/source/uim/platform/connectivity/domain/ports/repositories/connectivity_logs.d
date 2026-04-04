/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.connectivity_logs;

import uim.platform.connectivity.domain.entities.connectivity_log;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - connectivity event log persistence.
interface ConnectivityLogRepository {
  ConnectivityLog[] findByTenant(TenantId tenantId);
  ConnectivityLog[] findBySeverity(TenantId tenantId, LogSeverity severity);
  ConnectivityLog[] findBySource(string sourceId);
  void save(ConnectivityLog logEntry);
}

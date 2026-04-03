module uim.platform.connectivity.domain.ports.connectivity_log_repository;

import uim.platform.connectivity.domain.entities.connectivity_log;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - connectivity event log persistence.
interface ConnectivityLogRepository
{
  ConnectivityLog[] findByTenant(TenantId tenantId);
  ConnectivityLog[] findBySeverity(TenantId tenantId, LogSeverity severity);
  ConnectivityLog[] findBySource(string sourceId);
  void save(ConnectivityLog logEntry);
}

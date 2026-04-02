module uim.platform.connectivity.application.usecases.monitor_connectivity;

import domain.entities.connectivity_log;
import domain.ports.connectivity_log_repository;
import domain.types;

/// Summary of connectivity status for a tenant.
struct ConnectivitySummary
{
    ulong totalEvents;
    ulong infoCount;
    ulong warningCount;
    ulong errorCount;
    ulong criticalCount;
}

/// Application service for connectivity monitoring and log queries.
class MonitorConnectivityUseCase
{
    private ConnectivityLogRepository logRepo;

    this(ConnectivityLogRepository logRepo)
    {
        this.logRepo = logRepo;
    }

    ConnectivityLog[] listLogs(TenantId tenantId)
    {
        return logRepo.findByTenant(tenantId);
    }

    ConnectivityLog[] listBySeverity(TenantId tenantId, LogSeverity severity)
    {
        return logRepo.findBySeverity(tenantId, severity);
    }

    ConnectivityLog[] listBySource(string sourceId)
    {
        return logRepo.findBySource(sourceId);
    }

    ConnectivitySummary getSummary(TenantId tenantId)
    {
        auto logs = logRepo.findByTenant(tenantId);
        ConnectivitySummary summary;
        summary.totalEvents = logs.length;

        foreach (log; logs)
        {
            final switch (log.severity)
            {
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

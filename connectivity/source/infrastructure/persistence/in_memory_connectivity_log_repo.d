module infrastructure.persistence.memory.connectivity_log_repo;

import domain.types;
import domain.entities.connectivity_log;
import domain.ports.connectivity_log_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryConnectivityLogRepository : ConnectivityLogRepository
{
    private ConnectivityLog[] logs;

    ConnectivityLog[] findByTenant(TenantId tenantId)
    {
        return logs.filter!(e => e.tenantId == tenantId).array;
    }

    ConnectivityLog[] findBySeverity(TenantId tenantId, LogSeverity severity)
    {
        return logs.filter!(e => e.tenantId == tenantId && e.severity == severity).array;
    }

    ConnectivityLog[] findBySource(string sourceId)
    {
        return logs.filter!(e => e.sourceId == sourceId).array;
    }

    void save(ConnectivityLog entry) { logs ~= entry; }
}

module infrastructure.persistence.in_memory_data_access_repo;

import domain.types;
import domain.entities.data_access_log;
import domain.ports.data_access_log_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryDataAccessLogRepository : DataAccessLogRepository
{
    private DataAccessLog[] store;

    DataAccessLog[] findByTenant(TenantId tenantId)
    {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    DataAccessLog* findByAuditLogId(AuditLogId auditLogId, TenantId tenantId)
    {
        foreach (ref e; store)
            if (e.auditLogId == auditLogId && e.tenantId == tenantId)
                return &e;
        return null;
    }

    DataAccessLog[] findByAccessor(TenantId tenantId, UserId accessedBy)
    {
        return store.filter!(e => e.tenantId == tenantId && e.accessedBy == accessedBy).array;
    }

    DataAccessLog[] findByDataSubject(TenantId tenantId, string dataSubject)
    {
        return store.filter!(e => e.tenantId == tenantId && e.dataSubject == dataSubject).array;
    }

    DataAccessLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo)
    {
        return store.filter!(e => e.tenantId == tenantId
            && e.timestamp >= timeFrom && e.timestamp <= timeTo).array;
    }

    void save(DataAccessLog log) { store ~= log; }

    void removeOlderThan(TenantId tenantId, long beforeTimestamp)
    {
        store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
    }
}

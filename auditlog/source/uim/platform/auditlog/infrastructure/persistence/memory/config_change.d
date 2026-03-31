module uim.platform.auditlog.infrastructure.persistence.in_memory_config_change_repo;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.config_change_log;
import uim.platform.auditlog.domain.ports.config_change_log_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryConfigChangeLogRepository : ConfigChangeLogRepository
{
    private ConfigChangeLog[] store;

    ConfigChangeLog[] findByTenant(TenantId tenantId)
    {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ConfigChangeLog* findByAuditLogId(AuditLogId auditLogId, TenantId tenantId)
    {
        foreach (ref e; store)
            if (e.auditLogId == auditLogId && e.tenantId == tenantId)
                return &e;
        return null;
    }

    ConfigChangeLog[] findByUser(TenantId tenantId, UserId changedBy)
    {
        return store.filter!(e => e.tenantId == tenantId && e.changedBy == changedBy).array;
    }

    ConfigChangeLog[] findByConfigType(TenantId tenantId, string configType)
    {
        return store.filter!(e => e.tenantId == tenantId && e.configType == configType).array;
    }

    ConfigChangeLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo)
    {
        return store.filter!(e => e.tenantId == tenantId
            && e.timestamp >= timeFrom && e.timestamp <= timeTo).array;
    }

    void save(ConfigChangeLog log) { store ~= log; }

    void removeOlderThan(TenantId tenantId, long beforeTimestamp)
    {
        store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
    }
}

module uim.platform.auditlog.infrastructure.persistence.memory.config_change;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.config_change_log;
import uim.platform.auditlog.domain.ports.config_change_log_repository;

import std.algorithm : filter;
import std.array : array;

@safe:
class InMemoryConfigChangeLogRepository : ConfigChangeLogRepository {
    private ConfigChangeLog[] store;

    bool existsByAuditLogId(AuditLogId auditLogId, TenantId tenantId) {
        return store.any!(e => e.auditLogId == auditLogId && e.tenantId == tenantId);
    }

    ConfigChangeLog findByAuditLogId(AuditLogId auditLogId, TenantId tenantId) {
        foreach (e; store)
            if (e.auditLogId == auditLogId && e.tenantId == tenantId)
                return e;
        return ConfigChangeLog.init;
    }

    ConfigChangeLog[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ConfigChangeLog[] findByUser(TenantId tenantId, UserId changedBy) {
        return findByTenant(tenantId).filter!(e => e.changedBy == changedBy).array;
    }

    ConfigChangeLog[] findByConfigType(TenantId tenantId, string configType) {
        return findByTenant(tenantId).filter!(e => e.configType == configType).array;
    }

    ConfigChangeLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
        return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo).array;
    }

    void save(ConfigChangeLog log) {
        store ~= log;
    }

    void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
        store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp))
            .array;
    }
}

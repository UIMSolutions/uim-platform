module domain.ports.config_change_log_repository;

import domain.types;
import domain.entities.config_change_log;

/// Port for persisting configuration change log records.
interface ConfigChangeLogRepository
{
    ConfigChangeLog[] findByTenant(TenantId tenantId);
    ConfigChangeLog* findByAuditLogId(AuditLogId auditLogId, TenantId tenantId);
    ConfigChangeLog[] findByUser(TenantId tenantId, UserId changedBy);
    ConfigChangeLog[] findByConfigType(TenantId tenantId, string configType);
    ConfigChangeLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
    void save(ConfigChangeLog log);
    void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

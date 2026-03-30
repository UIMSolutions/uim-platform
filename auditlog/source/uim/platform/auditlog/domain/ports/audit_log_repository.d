module domain.ports.audit_log_repository;

import domain.types;
import domain.entities.audit_log_entry;

/// Port for persisting and querying audit log entries.
interface AuditLogRepository
{
    AuditLogEntry[] findByTenant(TenantId tenantId);
    AuditLogEntry* findById(AuditLogId id, TenantId tenantId);
    AuditLogEntry[] findByCategory(TenantId tenantId, AuditCategory category);
    AuditLogEntry[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
    AuditLogEntry[] findByUser(TenantId tenantId, UserId userId);
    AuditLogEntry[] findByService(TenantId tenantId, ServiceId serviceId);
    AuditLogEntry[] findByCorrelation(string correlationId);
    AuditLogEntry[] search(TenantId tenantId, AuditCategory[] categories,
        long timeFrom, long timeTo, int limit, int offset);
    long countByTenant(TenantId tenantId);
    void save(AuditLogEntry entry);
    void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

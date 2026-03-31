module uim.platform.auditlog.domain.ports.security_event_repository;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.security_event;

/// Port for persisting enriched security events.
interface SecurityEventRepository
{
    SecurityEvent[] findByTenant(TenantId tenantId);
    SecurityEvent* findByAuditLogId(AuditLogId auditLogId, TenantId tenantId);
    SecurityEvent[] findByUser(TenantId tenantId, UserId userId);
    SecurityEvent[] findByOutcome(TenantId tenantId, AuditOutcome outcome);
    SecurityEvent[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
    void save(SecurityEvent event);
    void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}

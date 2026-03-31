module uim.platform.auditlog.infrastructure.persistence.in_memory_security_event_repo;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.security_event;
import uim.platform.auditlog.domain.ports.security_event_repository;

import std.algorithm : filter;
import std.array : array;

class InMemorySecurityEventRepository : SecurityEventRepository
{
    private SecurityEvent[] store;

    SecurityEvent[] findByTenant(TenantId tenantId)
    {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    SecurityEvent* findByAuditLogId(AuditLogId auditLogId, TenantId tenantId)
    {
        foreach (ref e; store)
            if (e.auditLogId == auditLogId && e.tenantId == tenantId)
                return &e;
        return null;
    }

    SecurityEvent[] findByUser(TenantId tenantId, UserId userId)
    {
        return store.filter!(e => e.tenantId == tenantId && e.userId == userId).array;
    }

    SecurityEvent[] findByOutcome(TenantId tenantId, AuditOutcome outcome)
    {
        return store.filter!(e => e.tenantId == tenantId && e.outcome == outcome).array;
    }

    SecurityEvent[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo)
    {
        return store.filter!(e => e.tenantId == tenantId
            && e.timestamp >= timeFrom && e.timestamp <= timeTo).array;
    }

    void save(SecurityEvent event) { store ~= event; }

    void removeOlderThan(TenantId tenantId, long beforeTimestamp)
    {
        store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
    }
}

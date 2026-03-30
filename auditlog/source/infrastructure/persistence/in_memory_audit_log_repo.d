module infrastructure.persistence.in_memory_audit_log_repo;

import domain.types;
import domain.entities.audit_log_entry;
import domain.ports.audit_log_repository;

import std.algorithm : filter, sort;
import std.array : array;

class InMemoryAuditLogRepository : AuditLogRepository
{
    private AuditLogEntry[AuditLogId] store;

    AuditLogEntry[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    AuditLogEntry* findById(AuditLogId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    AuditLogEntry[] findByCategory(TenantId tenantId, AuditCategory category)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.category == category)
            .array;
    }

    AuditLogEntry[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId
                && e.timestamp >= timeFrom && e.timestamp <= timeTo)
            .array;
    }

    AuditLogEntry[] findByUser(TenantId tenantId, UserId userId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.userId == userId)
            .array;
    }

    AuditLogEntry[] findByService(TenantId tenantId, ServiceId serviceId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.serviceId == serviceId)
            .array;
    }

    AuditLogEntry[] findByCorrelation(string correlationId)
    {
        return store.byValue()
            .filter!(e => e.correlationId == correlationId)
            .array;
    }

    AuditLogEntry[] search(TenantId tenantId, AuditCategory[] categories,
        long timeFrom, long timeTo, int limit, int offset)
    {
        auto filtered = store.byValue()
            .filter!(e => e.tenantId == tenantId)
            .filter!((e) {
                if (timeFrom > 0 && e.timestamp < timeFrom) return false;
                if (timeTo > 0 && e.timestamp > timeTo) return false;
                if (categories.length > 0)
                {
                    bool found = false;
                    foreach (c; categories)
                        if (e.category == c) { found = true; break; }
                    if (!found) return false;
                }
                return true;
            }).array;

        // Sort by timestamp descending
        filtered.sort!((a, b) => a.timestamp > b.timestamp);

        // Apply pagination
        if (offset >= filtered.length)
            return [];
        auto end = offset + limit;
        if (end > filtered.length)
            end = cast(int) filtered.length;
        return filtered[offset .. end];
    }

    long countByTenant(TenantId tenantId)
    {
        long count = 0;
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId)
                ++count;
        return count;
    }

    void save(AuditLogEntry entry) { store[entry.id] = entry; }

    void removeOlderThan(TenantId tenantId, long beforeTimestamp)
    {
        AuditLogId[] toRemove;
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.timestamp < beforeTimestamp)
                toRemove ~= e.id;
        foreach (id; toRemove)
            store.remove(id);
    }
}

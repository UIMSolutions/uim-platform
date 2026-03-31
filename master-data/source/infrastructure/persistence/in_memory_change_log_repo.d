module infrastructure.persistence.in_memory_change_log_repo;

import domain.types;
import domain.entities.change_log_entry;
import domain.ports.change_log_repository;

import std.algorithm : filter, sort;
import std.array : array;

class InMemoryChangeLogRepository : ChangeLogRepository
{
    private ChangeLogEntry[ChangeLogEntryId] store;

    ChangeLogEntry findById(ChangeLogEntryId id)
    {
        if (auto p = id in store)
            return *p;
        return ChangeLogEntry.init;
    }

    ChangeLogEntry[] findByTenant(TenantId tenantId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId)
            .array
            .sort!((a, b) => a.timestamp < b.timestamp)
            .array;
    }

    ChangeLogEntry[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.objectId == objectId)
            .array
            .sort!((a, b) => a.timestamp < b.timestamp)
            .array;
    }

    ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.category == category)
            .array
            .sort!((a, b) => a.timestamp < b.timestamp)
            .array;
    }

    ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken)
    {
        // Find the timestamp associated with the delta token
        long tokenTimestamp = 0;
        foreach (ref entry; store.byValue())
        {
            if (entry.tenantId == tenantId && entry.deltaToken == deltaToken)
            {
                tokenTimestamp = entry.timestamp;
                break;
            }
        }
        // Return all entries after that timestamp
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.timestamp > tokenTimestamp)
            .array
            .sort!((a, b) => a.timestamp < b.timestamp)
            .array;
    }

    ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.timestamp > sinceTimestamp)
            .array
            .sort!((a, b) => a.timestamp < b.timestamp)
            .array;
    }

    void save(ChangeLogEntry entry) { store[entry.id] = entry; }
    void remove(ChangeLogEntryId id) { store.remove(id); }
}

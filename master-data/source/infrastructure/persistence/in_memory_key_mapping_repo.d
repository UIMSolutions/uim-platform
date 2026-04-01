module infrastructure.persistence.memory.key_mapping_repo;

import domain.types;
import domain.entities.key_mapping;
import domain.ports.key_mapping_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryKeyMappingRepository : KeyMappingRepository
{
    private KeyMapping[KeyMappingId] store;

    KeyMapping findById(KeyMappingId id)
    {
        if (auto p = id in store)
            return *p;
        return KeyMapping.init;
    }

    KeyMapping[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    KeyMapping[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.masterDataObjectId == objectId)
            .array;
    }

    KeyMapping[] findByCategory(TenantId tenantId, MasterDataCategory category)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.category == category)
            .array;
    }

    KeyMapping findByClientKey(TenantId tenantId, ClientId clientId, string localKey)
    {
        foreach (ref mapping; store.byValue())
        {
            if (mapping.tenantId != tenantId)
                continue;
            foreach (ref entry; mapping.entries)
            {
                if (entry.clientId == clientId && entry.localKey == localKey)
                    return mapping;
            }
        }
        return KeyMapping.init;
    }

    void save(KeyMapping mapping) { store[mapping.id] = mapping; }
    void update(KeyMapping mapping) { store[mapping.id] = mapping; }
    void remove(KeyMappingId id) { store.remove(id); }
}

module uim.platform.xyz.infrastructure.persistence.memory.match_group_repo;

import domain.types;
import domain.entities.match_group;
import domain.ports.match_group_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryMatchGroupRepository : MatchGroupRepository
{
    private MatchGroup[MatchGroupId] store;

    MatchGroup[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(g => g.tenantId == tenantId).array;
    }

    MatchGroup* findById(MatchGroupId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    MatchGroup[] findByDataset(TenantId tenantId, DatasetId datasetId)
    {
        return store.byValue()
            .filter!(g => g.tenantId == tenantId && g.datasetId == datasetId)
            .array;
    }

    MatchGroup[] findUnresolved(TenantId tenantId)
    {
        return store.byValue()
            .filter!(g => g.tenantId == tenantId && !g.resolved)
            .array;
    }

    void save(MatchGroup group) { store[group.id] = group; }
    void update(MatchGroup group) { store[group.id] = group; }
    void remove(MatchGroupId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}

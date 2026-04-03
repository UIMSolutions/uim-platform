module uim.platform.workzone.infrastructure.persistence.memory.workpage_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workpage;
import uim.platform.workzone.domain.ports.workpage_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryWorkpageRepository : WorkpageRepository
{
    private Workpage[WorkpageId] store;

    Workpage[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
    {
        return store.byValue().filter!(p => p.tenantId == tenantId && p.workspaceId == workspaceId).array;
    }

    Workpage* findById(WorkpageId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    void save(Workpage page) { store[page.id] = page; }
    void update(Workpage page) { store[page.id] = page; }
    void remove(WorkpageId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}

module uim.platform.kyma.infrastructure.persistence.memory.namespace_repo;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.namespace;
import uim.platform.kyma.domain.ports.namespace_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryNamespaceRepository : NamespaceRepository
{
    private Namespace[NamespaceId] store;

    Namespace findById(NamespaceId id)
    {
        if (auto p = id in store)
            return *p;
        return Namespace.init;
    }

    Namespace findByName(KymaEnvironmentId envId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.environmentId == envId && e.name == name)
                return e;
        return Namespace.init;
    }

    Namespace[] findByEnvironment(KymaEnvironmentId envId)
    {
        return store.byValue().filter!(e => e.environmentId == envId).array;
    }

    Namespace[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    void save(Namespace ns) { store[ns.id] = ns; }
    void update(Namespace ns) { store[ns.id] = ns; }
    void remove(NamespaceId id) { store.remove(id); }
}

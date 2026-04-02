module infrastructure.persistence.memory.destination_repo;

import domain.types;
import domain.entities.destination;
import domain.ports.destination_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryDestinationRepository : DestinationRepository
{
    private Destination[DestinationId] store;

    Destination findById(DestinationId id)
    {
        if (auto p = id in store)
            return *p;
        return Destination.init;
    }

    Destination findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return e;
        return Destination.init;
    }

    Destination[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    Destination[] findByProxyType(TenantId tenantId, ProxyType proxyType)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.proxyType == proxyType)
            .array;
    }

    void save(Destination entity) { store[entity.id] = entity; }
    void update(Destination entity) { store[entity.id] = entity; }
    void remove(DestinationId id) { store.remove(id); }
}

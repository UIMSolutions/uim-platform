module uim.platform.object_store.infrastructure.persistence.in_memory_service_binding_repo;

import domain.types;
import domain.entities.service_binding;
import domain.ports.service_binding_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryServiceBindingRepository : ServiceBindingRepository
{
    private ServiceBinding[ServiceBindingId] store;

    ServiceBinding findById(ServiceBindingId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    ServiceBinding[] findByBucket(BucketId bucketId)
    {
        return store.byValue().filter!(e => e.bucketId == bucketId).array;
    }

    ServiceBinding[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    void save(ServiceBinding entity) { store[entity.id] = entity; }
    void update(ServiceBinding entity) { store[entity.id] = entity; }
    void remove(ServiceBindingId id) { store.remove(id); }
}

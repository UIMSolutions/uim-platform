module uim.platform.object_store.infrastructure.persistence.memory.access_policy;

import uim.platform.object_store.domain.types;
import uim.platform.object_store.domain.entities.access_policy;
import uim.platform.object_store.domain.ports.repositories.access_policy;

import std.algorithm : filter;
import std.array : array;

class InMemoryAccessPolicyRepository : AccessPolicyRepository
{
    private AccessPolicy[AccessPolicyId] store;

    AccessPolicy findById(AccessPolicyId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    AccessPolicy[] findByBucket(BucketId bucketId)
    {
        return store.byValue().filter!(e => e.bucketId == bucketId).array;
    }

    AccessPolicy[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    void save(AccessPolicy entity) { store[entity.id] = entity; }
    void update(AccessPolicy entity) { store[entity.id] = entity; }
    void remove(AccessPolicyId id) { store.remove(id); }
}

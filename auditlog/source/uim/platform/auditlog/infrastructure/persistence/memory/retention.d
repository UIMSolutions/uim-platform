module infrastructure.persistence.in_memory_retention_repo;

import domain.types;
import domain.entities.retention_policy;
import domain.ports.retention_policy_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryRetentionPolicyRepository : RetentionPolicyRepository
{
    private RetentionPolicy[RetentionPolicyId] store;

    RetentionPolicy[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(p => p.tenantId == tenantId).array;
    }

    RetentionPolicy* findById(RetentionPolicyId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    RetentionPolicy* findDefault(TenantId tenantId)
    {
        foreach (ref p; store.byValue())
            if (p.tenantId == tenantId && p.isDefault && p.status == RetentionStatus.active)
                return &p;
        return null;
    }

    void save(RetentionPolicy policy) { store[policy.id] = policy; }
    void update(RetentionPolicy policy) { store[policy.id] = policy; }
    void remove(RetentionPolicyId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}

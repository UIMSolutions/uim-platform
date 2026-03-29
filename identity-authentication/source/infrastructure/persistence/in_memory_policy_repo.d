module uim.platform.identity_authentication.infrastructure.persistence.in_memory_policy;

import domain.entities.policy;
import domain.types;
import domain.ports.policy;

import std.algorithm : canFind;

/// In-memory adapter for authorization policy persistence.
class InMemoryPolicyRepository : PolicyRepository
{
    private AuthorizationPolicy[PolicyId] store;

    AuthorizationPolicy findById(PolicyId id)
    {
        if (auto p = id in store)
            return *p;
        return AuthorizationPolicy.init;
    }

    AuthorizationPolicy[] findByTenant(TenantId tenantId)
    {
        AuthorizationPolicy[] result;
        foreach (p; store.byValue())
        {
            if (p.tenantId == tenantId)
                result ~= p;
        }
        return result;
    }

    AuthorizationPolicy[] findByApplication(ApplicationId appId)
    {
        AuthorizationPolicy[] result;
        foreach (p; store.byValue())
        {
            if (p.applicationIds.canFind(appId))
                result ~= p;
        }
        return result;
    }

    void save(AuthorizationPolicy policy)
    {
        store[policy.id] = policy;
    }

    void update(AuthorizationPolicy policy)
    {
        store[policy.id] = policy;
    }

    void remove(PolicyId id)
    {
        store.remove(id);
    }
}

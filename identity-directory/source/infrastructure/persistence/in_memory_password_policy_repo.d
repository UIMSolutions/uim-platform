module infrastructure.persistence.in_memory_password_policy_repo;

import domain.entities.password_policy;
import domain.types;
import domain.ports.password_policy_repository;

/// In-memory adapter for password policy persistence.
class InMemoryPasswordPolicyRepository : PasswordPolicyRepository
{
    private PasswordPolicy[string] store;

    PasswordPolicy findById(string id)
    {
        if (auto p = id in store)
            return *p;
        return PasswordPolicy.init;
    }

    PasswordPolicy findActiveForTenant(TenantId tenantId)
    {
        foreach (p; store.byValue())
        {
            if (p.tenantId == tenantId && p.active)
                return p;
        }
        return PasswordPolicy.init;
    }

    PasswordPolicy[] findByTenant(TenantId tenantId)
    {
        PasswordPolicy[] result;
        foreach (p; store.byValue())
        {
            if (p.tenantId == tenantId)
                result ~= p;
        }
        return result;
    }

    void save(PasswordPolicy policy)
    {
        store[policy.id] = policy;
    }

    void update(PasswordPolicy policy)
    {
        store[policy.id] = policy;
    }

    void remove(string id)
    {
        store.remove(id);
    }
}

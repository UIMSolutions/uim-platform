module uim.platform.xyz.domain.ports.security_policy_repository;

import uim.platform.xyz.domain.entities.security_policy;
import uim.platform.xyz.domain.types;

/// Port: outgoing — security policy persistence.
interface SecurityPolicyRepository
{
    SecurityPolicy findById(SecurityPolicyId id);
    SecurityPolicy[] findByTenant(TenantId tenantId);
    void save(SecurityPolicy policy);
    void update(SecurityPolicy policy);
    void remove(SecurityPolicyId id);
}

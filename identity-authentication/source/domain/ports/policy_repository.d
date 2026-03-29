module domain.ports.policy_repository;

import domain.entities.policy;
import domain.types;

/// Port: outgoing — authorization policy persistence.
interface PolicyRepository
{
    AuthorizationPolicy findById(PolicyId id);
    AuthorizationPolicy[] findByTenant(TenantId tenantId);
    AuthorizationPolicy[] findByApplication(ApplicationId appId);
    void save(AuthorizationPolicy policy);
    void update(AuthorizationPolicy policy);
    void remove(PolicyId id);
}

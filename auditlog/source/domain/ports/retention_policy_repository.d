module domain.ports.retention_policy_repository;

import domain.types;
import domain.entities.retention_policy;

/// Port for persisting retention policies.
interface RetentionPolicyRepository
{
    RetentionPolicy[] findByTenant(TenantId tenantId);
    RetentionPolicy* findById(RetentionPolicyId id, TenantId tenantId);
    RetentionPolicy* findDefault(TenantId tenantId);
    void save(RetentionPolicy policy);
    void update(RetentionPolicy policy);
    void remove(RetentionPolicyId id, TenantId tenantId);
}

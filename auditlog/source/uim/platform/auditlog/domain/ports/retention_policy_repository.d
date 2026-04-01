module uim.platform.auditlog.domain.ports.retention_policy_repository;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.retention_policy;

/// Port for persisting retention policies.
@safe:
interface RetentionPolicyRepository {
    bool existsById(RetentionPolicyId id, TenantId tenantId);
    RetentionPolicy findById(RetentionPolicyId id, TenantId tenantId);

    bool existsDefault(TenantId tenantId);
    RetentionPolicy findDefault(TenantId tenantId);

    RetentionPolicy[] findByTenant(TenantId tenantId);
    
    void save(RetentionPolicy policy);
    void update(RetentionPolicy policy);
    void remove(RetentionPolicyId id, TenantId tenantId);
}

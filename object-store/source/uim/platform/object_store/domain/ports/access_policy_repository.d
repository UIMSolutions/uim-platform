module domain.ports.access_policy_repository;

import domain.entities.access_policy;
import domain.types;

/// Port: outgoing - access policy persistence.
interface AccessPolicyRepository
{
    AccessPolicy findById(AccessPolicyId id);
    AccessPolicy[] findByBucket(BucketId bucketId);
    AccessPolicy[] findByTenant(TenantId tenantId);
    void save(AccessPolicy policy);
    void update(AccessPolicy policy);
    void remove(AccessPolicyId id);
}

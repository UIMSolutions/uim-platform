module uim.platform.object_store.domain.ports.repositories.access_policy;

import uim.platform.object_store.domain.entities.access_policy;
import uim.platform.object_store.domain.types;

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

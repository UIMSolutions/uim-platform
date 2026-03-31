module uim.platform.object_store.domain.ports.repositories.bucket;

import uim.platform.object_store.domain.entities.bucket;
import uim.platform.object_store.domain.types;

/// Port: outgoing - bucket persistence.
interface BucketRepository
{
    Bucket findById(BucketId id);
    Bucket findByName(TenantId tenantId, string name);
    Bucket[] findByTenant(TenantId tenantId);
    void save(Bucket bucket);
    void update(Bucket bucket);
    void remove(BucketId id);
}

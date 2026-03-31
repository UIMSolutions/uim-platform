module domain.ports.bucket_repository;

import domain.entities.bucket;
import domain.types;

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

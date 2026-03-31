module uim.platform.object_store.domain.ports.service_binding_repository;

import domain.entities.service_binding;
import domain.types;

/// Port: outgoing - service binding persistence.
interface ServiceBindingRepository
{
    ServiceBinding findById(ServiceBindingId id);
    ServiceBinding[] findByBucket(BucketId bucketId);
    ServiceBinding[] findByTenant(TenantId tenantId);
    void save(ServiceBinding binding);
    void update(ServiceBinding binding);
    void remove(ServiceBindingId id);
}

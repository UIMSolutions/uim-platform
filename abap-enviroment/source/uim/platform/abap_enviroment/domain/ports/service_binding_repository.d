module domain.ports.service_binding_repository;

import domain.entities.service_binding;
import domain.types;

/// Port: outgoing - service binding persistence.
interface ServiceBindingRepository
{
    ServiceBinding* findById(ServiceBindingId id);
    ServiceBinding[] findBySystem(SystemInstanceId systemId);
    ServiceBinding[] findByTenant(TenantId tenantId);
    ServiceBinding[] findByType(SystemInstanceId systemId, BindingType bindingType);
    void save(ServiceBinding binding);
    void update(ServiceBinding binding);
    void remove(ServiceBindingId id);
}

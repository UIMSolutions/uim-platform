module uim.platform.abap_enviroment.domain.ports.service_binding_repository;

import uim.platform.abap_enviroment.domain.entities.service_binding;
import uim.platform.abap_enviroment.domain.types;

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

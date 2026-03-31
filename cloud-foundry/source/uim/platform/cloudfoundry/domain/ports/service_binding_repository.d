module domain.ports.service_binding_repository;

import domain.types;
import domain.entities.service_binding;

/// Port for persisting and querying service bindings.
interface ServiceBindingRepository
{
  ServiceBinding[] findByApp(AppId appId, TenantId tenantId);
  ServiceBinding* findById(ServiceBindingId id, TenantId tenantId);
  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId, TenantId tenantId);
  ServiceBinding[] findByTenant(TenantId tenantId);
  void save(ServiceBinding binding);
  void update(ServiceBinding binding);
  void remove(ServiceBindingId id, TenantId tenantId);
  void removeByApp(AppId appId, TenantId tenantId);
}

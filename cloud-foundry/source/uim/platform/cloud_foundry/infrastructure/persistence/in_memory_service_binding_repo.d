module infrastructure.persistence.in_memory_service_binding_repo;

import domain.types;
import domain.entities.service_binding;
import domain.ports.service_binding_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryServiceBindingRepository : ServiceBindingRepository
{
  private ServiceBinding[ServiceBindingId] store;

  ServiceBinding[] findByApp(AppId appId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.appId == appId)
      .array;
  }

  ServiceBinding* findById(ServiceBindingId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.serviceInstanceId == instanceId)
      .array;
  }

  ServiceBinding[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void removeByApp(AppId appId, TenantId tenantId)
  {
    ServiceBindingId[] toRemove;
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.appId == appId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  void save(ServiceBinding binding) { store[binding.id] = binding; }
  void update(ServiceBinding binding) { store[binding.id] = binding; }

  void remove(ServiceBindingId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}

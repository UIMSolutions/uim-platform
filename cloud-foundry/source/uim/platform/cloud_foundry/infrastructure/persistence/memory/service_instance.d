module uim.platform.cloud_foundry.infrastructure.persistence.memory.service_instance;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.service_instance;
import uim.platform.cloud_foundry.domain.ports.service_instance;

import std.algorithm : filter;
import std.array : array;

class MemoryServiceInstanceRepository : ServiceInstanceRepository
{
  private ServiceInstance[ServiceInstanceId] store;

  ServiceInstance[] findBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.spaceId == spaceId)
      .array;
  }

  ServiceInstance* findById(ServiceInstanceId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ServiceInstance* findByName(SpaceId spaceId, TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.spaceId == spaceId && e.name == name)
        return &e;
    return null;
  }

  ServiceInstance[] findByServiceName(SpaceId spaceId, TenantId tenantId, string serviceName)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.spaceId == spaceId && e.serviceName == serviceName)
      .array;
  }

  ServiceInstance[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(ServiceInstance instance) { store[instance.id] = instance; }
  void update(ServiceInstance instance) { store[instance.id] = instance; }

  void remove(ServiceInstanceId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}

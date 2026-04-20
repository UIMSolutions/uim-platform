/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.service_instance;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_instance;
// import uim.platform.foundry.domain.ports.repositories.service_instance;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryServiceInstanceRepository : ServiceInstanceRepository {
  private ServiceInstance[ServiceInstanceId] store;

  ServiceInstance[] findBySpace(SpaceId spacetenantId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.spaceId == spaceId).array;
  }

  ServiceInstance* findById(ServiceInstanceId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ServiceInstance* findByName(SpaceId spacetenantId, id tenantId, string name) {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.spaceId == spaceId && e.name == name)
        return &e;
    return null;
  }

  ServiceInstance[] findByServiceName(SpaceId spacetenantId, id tenantId, string serviceName) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.spaceId == spaceId && e.serviceName == serviceName).array;
  }

  ServiceInstance[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(ServiceInstance instance) {
    store[instance.id] = instance;
  }

  void update(ServiceInstance instance) {
    store[instance.id] = instance;
  }

  void remove(ServiceInstanceId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}

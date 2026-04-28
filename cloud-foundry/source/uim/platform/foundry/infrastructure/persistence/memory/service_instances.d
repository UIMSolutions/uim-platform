/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.service_instances;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_instance;
// import uim.platform.foundry.domain.ports.repositories.service_instance;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryServiceInstanceRepository : TenantRepository!(ServiceInstance, ServiceInstanceId), IServiceInstanceRepository {

  bool existsByName(TenantId tenantId, SpaceId spaceId, string name) {
    return findByName(tenantId, spaceId, name).id.value != "";
  }

  ServiceInstance findByName(TenantId tenantId, SpaceId spaceId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.spaceId == spaceId && e.name == name)
        return e;
    return ServiceInstance.init;
  }

  void removeByName(TenantId tenantId, SpaceId spaceId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.spaceId == spaceId && e.name == name)
        return remove(e);
  }

  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }

  ServiceInstance[] filterBySpace(ServiceInstance[] instances, SpaceId spaceId) {
    return instances.filter!(e => e.spaceId == spaceId).array;
  }

  ServiceInstance[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }

  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(e => remove(e));
  }

  size_t countByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName) {
    return findByServiceName(tenantId, spaceId, serviceName).length;
  }

  ServiceInstance[] filterByServiceName(ServiceInstance[] instances, string serviceName) {
    return instances.filter!(e => e.serviceName == serviceName).array;
  }

  ServiceInstance[] findByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName) {
    return filterByServiceName(findBySpace(tenantId, spaceId), serviceName);
  }

  void removeByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName) {
    findByServiceName(tenantId, spaceId, serviceName).each!(e => remove(e));
  }

}

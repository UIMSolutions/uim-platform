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

  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  ServiceInstance[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return findByTenant(tenantId).filter!(e => e.spaceId == spaceId).array;
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(e => remove(e.id));
  }

  size_t countByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName) {
    return findByServiceName(tenantId, spaceId, serviceName).length;
  }
  ServiceInstance[] findByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName) {
    return findByTenant(tenantId).filter!(e => e.spaceId == spaceId && e.serviceName == serviceName).array;
  }
  void removeByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName) {
    findByServiceName(tenantId, spaceId, serviceName).each!(e => remove(e));
  }

}

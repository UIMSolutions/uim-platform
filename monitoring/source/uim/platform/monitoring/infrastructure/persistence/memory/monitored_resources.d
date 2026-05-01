/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.monitored_resources;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.ports.repositories.monitored_resources;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryMonitoredResourceRepository : TenantRepository!(MonitoredResource, MonitoredResourceId), MonitoredResourceRepository {

  bool existsByName(TenantId tenantId, string name) {
    return (findByTenant(tenantId).any!(e => e.name == name));
  }

  MonitoredResource findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return MonitoredResource.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name) {
        remove(e);
        return;
      }
  }

  size_t countByType(TenantId tenantId, ResourceType type) {
    return findByType(tenantId, type).length;
  }

  MonitoredResource[] filterByType(MonitoredResource[] resources, ResourceType type) {
    return resources.filter!(res => res.resourceType = type).array;
  }

  MonitoredResource[] findByType(TenantId tenantId, ResourceType type) {
    return filterByType(findByTenant(tenantId), type);
  }

  void removeByType(TenantId tenantId, ResourceType type) {
    findByType.each!(res => remove(res));
  }
}

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
class MemoryMonitoredResourceRepository : MonitoredResourceRepository {
  private MonitoredResource[MonitoredResourceId] store;

  bool existsById(MonitoredResourceId id) {
    return (id in store) ? true : false;
  }

  MonitoredResource findById(MonitoredResourceId id) {
    return (existsById(id)) ? store[id] : MonitoredResource.init;
  }

  bool existsByName(TenantId tenantId, string name) {
    return (findByTenant(tenantId).any!(e => e.name == name));
  }

  MonitoredResource findByName(TenantId tenantId, string name) {
    foreach (e; findAll()
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return MonitoredResource.init;
  }

  MonitoredResource[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  MonitoredResource[] findByType(TenantId tenantId, ResourceType type) {
    return findAll()r!(e => e.tenantId == tenantId && e.resourceType == type).array;
  }

  void save(MonitoredResource resource) {
    store[resource.id] = resource;
  }

  void update(MonitoredResource resource) {
    store[resource.id] = resource;
  }

  void remove(MonitoredResourceId id) {
    store.remove(id);
  }
}

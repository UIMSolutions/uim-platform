/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.infrastructure.persistence.memory.software_component;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.software_component;
// import uim.platform.abap_enviroment.domain.ports.repositories.software_components;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:
class MemorySoftwareComponentRepository : SoftwareComponentRepository {
  private SoftwareComponent[SoftwareComponentId] store;

  bool existsById(SoftwareComponentId id) {
    return (id in store) ? true : false;
  }

  SoftwareComponent findById(SoftwareComponentId id) {
    return existsById(id) ? store[id] : SoftwareComponent.init;
  }

  SoftwareComponent[] findBySystem(SystemInstanceId systemId) {
    return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
  }

  SoftwareComponent[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  bool existsName(SystemInstanceId systemId, string name) {
    foreach (e; store.byValue())
      if (e.systemInstanceId == systemId && e.name == name)
        return true;
    return false;
  }

  SoftwareComponent findByName(SystemInstanceId systemId, string name) {
    foreach (e; store.byValue())
      if (e.systemInstanceId == systemId && e.name == name)
        return store[e.id];
    return SoftwareComponent.init;
  }

  void save(SoftwareComponent component) {
    store[component.id] = component;
  }

  void update(SoftwareComponent component) {
    store[component.id] = component;
  }

  void remove(SoftwareComponentId id) {
    store.remove(id);
  }
}

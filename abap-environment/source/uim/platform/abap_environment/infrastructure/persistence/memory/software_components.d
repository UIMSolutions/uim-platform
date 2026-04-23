/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.software_component;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.software_component;
// import uim.platform.abap_environment.domain.ports.repositories.software_components;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
class MemorySoftwareComponentRepository : TenantRepository!(SoftwareComponent, SoftwareComponentId), SoftwareComponentRepository {

  bool existsName(SystemInstanceId systemId, string name) {
    return findAll().any!(e => e.systemInstanceId == systemId && e.name == name);
  }

  SoftwareComponent findByName(SystemInstanceId systemId, string name) {
    foreach (e; findAll())
      if (e.systemInstanceId == systemId && e.name == name)
        return store[e.id];
    return SoftwareComponent.init;
  }

  void removeByName(SystemInstanceId systemId, string name) {
    foreach (e; findAll())
      if (e.systemInstanceId == systemId && e.name == name)
        remove(e.id);
  }

  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  SoftwareComponent[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.systemInstanceId == systemId).array;
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e.id));
  }
}

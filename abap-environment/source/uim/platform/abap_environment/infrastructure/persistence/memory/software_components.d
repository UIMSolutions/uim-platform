/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.software_components;

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

  bool existsByName(SystemInstanceId systemId, string name) {
    return findBySystem(systemId).any!(e => e.name == name);
  }

  SoftwareComponent findByName(SystemInstanceId systemId, string name) {
    foreach (e; findBySystem(systemId))
      if (e.name == name)
        return e;
    return SoftwareComponent.init;
  }

  void removeByName(SystemInstanceId systemId, string name) {
    foreach (e; findBySystem(systemId))
      if (e.name == name)
        remove(e);
  }

  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  SoftwareComponent[] filterBySystem(SoftwareComponent[] components, string nameFilter) {
    return components
      .filter!(e => e.name.contains(nameFilter, "i"))
      .array;
  }
  SoftwareComponent[] findBySystem(SystemInstanceId systemId) {
    return filterBySystem(findAll(), systemId);
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }
}

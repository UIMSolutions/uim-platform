/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.repositories.software_components;

// import uim.platform.abap_environment.domain.entities.software_component;
// import uim.platform.abap_environment.domain.ports.repositories.software_components;

import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:
class MemorySoftwareComponentRepository : TenantRepository!(SoftwareComponent, SoftwareComponentId), SoftwareComponentRepository {

  bool existsByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    return findBySystem(tenantId, systemId).any!(e => e.name == name);
  }

  SoftwareComponent findByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    foreach (e; findBySystem(tenantId, systemId))
      if (e.name == name)
        return e;
    return SoftwareComponent.init;
  }

  void removeByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    foreach (e; findBySystem(tenantId, systemId))
      if (e.name == name)
        remove(e);
  }

  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  SoftwareComponent[] filterBySystem(SoftwareComponent[] components, SystemInstanceId systemId) {
    return components
      .filter!(e => e.systemInstanceId == systemId)
      .array;
  }
  SoftwareComponent[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }

  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e));
  }
}

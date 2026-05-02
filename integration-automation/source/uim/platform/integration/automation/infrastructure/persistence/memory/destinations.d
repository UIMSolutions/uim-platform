/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.destinations;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.destination;

// // import uim.platform.integration.automation.domain.ports.repositories.destinations;
// import uim.platform.integration.automation.domain.ports;

import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:

class MemoryDestinationRepository : TenantRepository!(Destination, DestinationId), DestinationRepository {

  size_t countBySystem(TenantId tenantId, SystemConnectionId systemId) {
    return findBySystem(tenantId, systemId).length;
  }
  Destination[] filterBySystem(Destination[] destinations, SystemConnectionId systemId) {
    return destinations.filter!(d => d.systemId == systemId).array;
  }
  Destination[] findBySystem(TenantId tenantId, SystemConnectionId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }
  void removeBySystem(TenantId tenantId, SystemConnectionId systemId) {
    findBySystem(tenantId, systemId).each!(d => remove(d));
  }

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(d => d.name == name);
  }
  Destination findByName(TenantId tenantId, string name) {
    foreach (d; findByTenant(tenantId))
      if (d.name == name)
        return d;
    return Destination.init;
  }

  size_t countByEnabled(TenantId tenantId) {
    return findEnabled(tenantId).length;
  }
  Destination[] filterByEnabled(Destination[] destinations) {
    return destinations.filter!(d => d.isEnabled).array;
  }
  Destination[] findEnabled(TenantId tenantId) {
    return findByTenant(tenantId).filter!(d => d.isEnabled).array;
  }
  void removeByEnabled(TenantId tenantId) {
    findEnabled(tenantId).each!(d => remove(d));
  }

}

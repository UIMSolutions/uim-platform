/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.infrastructure.persistence.repositories.destinations;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class DestinationRepository : TenantRepository!(Destination, DestinationId), IDestinationRepository {

  size_t countBySystem(TenantId tenantId, SystemConnectionId systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  Destination[] filterBySystem(Destination[] destinations, SystemConnectionId systemId, size_t offset = 0, size_t limit = 0) {
    return destinations.filter!(d => d.systemId == systemId).array.skip(offset).take(limit).array;
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

  void removeByName(TenantId tenantId, string name) {
    findByTenant(tenantId).filter!(d => d.name == name)
      .each!(d => remove(d));
  }

  size_t countByEnabled(TenantId tenantId) {
    return findEnabled(tenantId).length;
  }

  Destination[] filterByEnabled(Destination[] destinations, size_t offset = 0, size_t limit = 0) {
    return destinations.filter!(d => d.isEnabled).array.skip(offset).take(limit).array;
  }

  Destination[] findEnabled(TenantId tenantId) {
    return findByTenant(tenantId).filter!(d => d.isEnabled).array;
  }

  void removeByEnabled(TenantId tenantId) {
    findEnabled(tenantId).each!(d => remove(d));
  }

}

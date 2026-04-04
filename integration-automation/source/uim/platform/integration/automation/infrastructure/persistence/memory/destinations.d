/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.destinations;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.destination;

// import uim.platform.integration.automation.domain.ports.destination_repository;
import uim.platform.integration.automation.domain.ports;

// import std.algorithm : filter;
// import std.array : array;

class MemoryDestinationRepository : DestinationRepository {
  private Destination[DestinationId] store;

  Destination[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Destination* findById(DestinationId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Destination[] findBySystem(TenantId tenantId, SystemId systemId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.systemId == systemId).array;
  }

  Destination* findByName(TenantId tenantId, string name) {
    foreach (ref d; store.byValue())
      if (d.tenantId == tenantId && d.name == name)
        return &d;
    return null;
  }

  Destination[] findEnabled(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.isEnabled).array;
  }

  void save(Destination destination) {
    store[destination.id] = destination;
  }

  void update(Destination destination) {
    store[destination.id] = destination;
  }

  void remove(DestinationId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}

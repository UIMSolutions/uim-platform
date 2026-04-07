/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.destination_repo;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.destination;
// import uim.platform.connectivity.domain.ports.repositories.destinations;
// 
// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryDestinationRepository : DestinationRepository {
  private Destination[DestinationId] store;

  Destination findById(DestinationId id) {
    if (auto p = id in store)
      return *p;
    return Destination.init;
  }

  Destination findByName(TenantId tenantId, string name) {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return Destination.init;
  }

  Destination[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Destination[] findByProxyType(TenantId tenantId, ProxyType proxyType) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.proxyType == proxyType).array;
  }

  void save(Destination entity) {
    store[entity.id] = entity;
  }

  void update(Destination entity) {
    store[entity.id] = entity;
  }

  void remove(DestinationId id) {
    store.remove(id);
  }
}

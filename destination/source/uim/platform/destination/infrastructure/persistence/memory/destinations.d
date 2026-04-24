/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.infrastructure.persistence.memory.destinations;

// import uim.platform.destination.domain.types;
// import uim.platform.destination.domain.entities.destination;
// import uim.platform.destination.domain.ports.repositories.destinations;

// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class MemoryDestinationRepository : DestinationRepository {
  private Destination[DestinationId] store;

  bool existsById(DestinationId id) {
    return (id in store) ? true : false;
  }

  Destination findById(DestinationId id) {
    if (auto p = id in store)
      return *p;
    return Destination.init;
  }

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    return findAll().any!(e => e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name);
  }

  Destination findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.name == name)
        return e;
    return Destination.init;
  }

  Destination[] findByTenant(TenantId tenantId) {
    return findAll().filter!(e => e.tenantId == tenantId).array;
  }

  Destination[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId).array;
  }

  Destination[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.serviceInstanceId == instanceId).array;
  }

  Destination[] findByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId && e.level == level).array;
  }

  void save(Destination dest) {
    store[dest.id] = dest;
  }

  void update(Destination dest) {
    store[dest.id] = dest;
  }

  void remove(DestinationId id) {
    store.remove(id);
  }
}

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
class MemoryDestinationRepository : TenantRepository!(Destination, DestinationId), DestinationRepository {

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    return findAll().any!(e => e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name);
  }

  Destination findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.name == name)
        return e;
    return Destination.init;
  }

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }
  Destination[] filterBySubaccount(Destination[] dests, TenantId tenantId, SubaccountId subaccountId) {
    return dests.filter!(e => e.tenantId == tenantId && e.subaccountId == subaccountId).array;
  }
  Destination[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId).array;
  }
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByServiceInstance(tenantId, instanceId).length;
  }
Destination[] filterByServiceInstance(Destination[] dests, TenantId tenantId, ServiceInstanceId instanceId) {
    return dests.filter!(e => e.tenantId == tenantId && e.serviceInstanceId == instanceId).array;
  }
  Destination[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.serviceInstanceId == instanceId).array;
  }
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(e => remove(e));
  }

  bool existsByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level) {
    return findAll().any!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId && e.level == level);
  }
  Destination[] findByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId && e.level == level).array;
  }

}

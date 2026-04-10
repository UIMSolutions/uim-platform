/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.entitlements;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.ports.repositories.entitlements;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryEntitlementRepository : EntitlementRepository {
  private Entitlement[EntitlementId] store;

  bool existsById(EntitlementId id) {
    return (id in store) ? true : false;
  }

  Entitlement findById(EntitlementId id) {
    return existsById(id) ? store[id] : Entitlement.init;
  }

  Entitlement[] findByGlobalAccount(GlobalAccountId globalAccountId) {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId).array;
  }

  Entitlement[] findBySubaccount(SubaccountId subaccountId) {
    return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
  }

  Entitlement[] findByDirectory(DirectoryId directoryId) {
    return store.byValue().filter!(e => e.directoryId == directoryId).array;
  }

  Entitlement[] findByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId) {
    return findByGlobalAccount(globalAccountId).filter!(e => e.servicePlanId == planId).array;
  }

  void save(Entitlement ent) {
    store[ent.id] = ent;
  }

  void update(Entitlement ent) {
    store[ent.id] = ent;
  }

  void remove(EntitlementId id) {
    store.remove(id);
  }
}

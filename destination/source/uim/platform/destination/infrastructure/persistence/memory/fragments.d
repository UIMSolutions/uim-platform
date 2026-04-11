/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.infrastructure.persistence.memory.fragments;

// import uim.platform.destination.domain.types;
// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.ports.repositories.fragments;

// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class MemoryFragmentRepository : FragmentRepository {
  private DestinationFragment[FragmentId] store;

  DestinationFragment findById(FragmentId id) {
    if (auto p = id in store)
      return *p;
    return DestinationFragment.init;
  }

  DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name)
        return e;
    return DestinationFragment.init;
  }

  DestinationFragment[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId).array;
  }

  void save(DestinationFragment fragment) {
    store[fragment.id] = fragment;
  }

  void update(DestinationFragment fragment) {
    store[fragment.id] = fragment;
  }

  void remove(FragmentId id) {
    store.remove(id);
  }
}

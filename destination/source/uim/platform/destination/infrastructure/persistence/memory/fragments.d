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
class MemoryFragmentRepository : TenantRepository!(DestinationFragment, FragmentId), FragmentRepository {

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    return findAll().any!(e => e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name);
  }
  DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.name == name)
        return e;
    return DestinationFragment.init;
  }

  void removeByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    findByName(tenantId, subaccountId, name).remove();
  }

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  DestinationFragment[] filterBySubaccount(DestinationFragment[] fragments, SubaccountId subaccountId) {
    return fragments.filter!(e => e.subaccountId == subaccountId).array;
  }

  DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

}

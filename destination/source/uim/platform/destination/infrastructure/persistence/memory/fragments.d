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

  DestinationFragment[] findByTenant(TenantId tenantId) {
    return findAll().filter!(e => e.tenantId == tenantId).array;
  }

  DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId).array;
  }

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.ports.repositories.fragments;

// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Port: outgoing — destination fragment persistence.
interface FragmentRepository : ITenantRepository!(DestinationFragment, FragmentId) {
  
  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name);
  DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  void removeByName(TenantId tenantId, SubaccountId subaccountId, string name);

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId);

}

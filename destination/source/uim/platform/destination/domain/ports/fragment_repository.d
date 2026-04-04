/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.ports.repositories.fragments;

import uim.platform.destination.domain.entities.destination_fragment;
import uim.platform.destination.domain.types;

/// Port: outgoing — destination fragment persistence.
interface FragmentRepository {
  DestinationFragment findById(FragmentId id);
  DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  DestinationFragment[] findByTenant(TenantId tenantId);
  DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void save(DestinationFragment fragment);
  void update(DestinationFragment fragment);
  void remove(FragmentId id);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.entitlements;

import uim.platform.management.domain.entities.entitlement;
import uim.platform.management.domain.types;

/// Port: outgoing — entitlement persistence.
interface EntitlementRepository {
  Entitlement findById(EntitlementId id);
  Entitlement findById(EntitlementId id);
  Entitlement[] findByGlobalAccount(GlobalAccountId globalAccountId);
  Entitlement[] findBySubaccount(SubaccountId subaccountId);
  Entitlement[] findByDirectory(DirectoryId directoryId);
  Entitlement[] findByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId);
  void save(Entitlement ent);
  void update(Entitlement ent);
  void remove(EntitlementId id);
}

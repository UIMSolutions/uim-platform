/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.entitlements;
// import uim.platform.management.domain.entities.entitlement;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — entitlement persistence.
interface EntitlementRepository : ITentRepository!(Entitlement, EntitlementId) {

  Entitlement[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  Entitlement[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Entitlement[] findByDirectory(TenantId tenantId, DirectoryId directoryId);
  Entitlement[] findByServicePlan(TenantId tenantId, GlobalAccountId globalAccountId, ServicePlanId planId);
  
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.subaccounts;
// import uim.platform.management.domain.entities.subaccount;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — subaccount persistence.
interface SubaccountRepository : ITenantRepository!(Subaccount, SubaccountId) {

  bool existsBySubdomain(TenantId tenantId, string subdomain);
  Subaccount findBySubdomain(TenantId tenantId, string subdomain);

  Subaccount[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  Subaccount[] findByDirectory(TenantId tenantId, DirectoryId directoryId);
  Subaccount[] findByRegion(TenantId tenantId, GlobalAccountId globalAccountId, string region);
  Subaccount[] findByStatus(TenantId tenantId, GlobalAccountId globalAccountId, SubaccountStatus status);
  
}

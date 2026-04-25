/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.subaccounts;

// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — subaccount persistence.
interface SubaccountRepository : IIdRepository!(Subaccount, SubaccountId) {

  bool existsBySubdomain(string subdomain);
  Subaccount findBySubdomain(string subdomain);

  Subaccount[] findByGlobalAccount(GlobalAccountId globalAccountId);
  Subaccount[] findByDirectory(DirectoryId directoryId);
  Subaccount[] findByRegion(GlobalAccountId globalAccountId, string region);
  Subaccount[] findByStatus(GlobalAccountId globalAccountId, SubaccountStatus status);
  
}

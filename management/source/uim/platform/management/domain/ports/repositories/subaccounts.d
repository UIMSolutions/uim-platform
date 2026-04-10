/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.subaccount;

import uim.platform.management.domain.entities.subaccount;
import uim.platform.management.domain.types;

/// Port: outgoing — subaccount persistence.
interface SubaccountRepository {
  Subaccount findById(SubaccountId id);
  Subaccount findBySubdomain(string subdomain);
  Subaccount[] findByGlobalAccount(GlobalAccountId globalAccountId);
  Subaccount[] findByDirectory(DirectoryId directoryId);
  Subaccount[] findByRegion(GlobalAccountId globalAccountId, string region);
  Subaccount[] findByStatus(GlobalAccountId globalAccountId, SubaccountStatus status);
  void save(Subaccount sub);
  void update(Subaccount sub);
  void remove(SubaccountId id);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.business_users;

import uim.platform.abap_enviroment.domain.entities.business_user;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - business user persistence.
interface BusinessUserRepository : ITenantRepository!(BusinessUser, BusinessUserId) {
  // BusinessUser* findById(BusinessUserId id);
  BusinessUser[] findBySystem(SystemInstanceId systemId);
  // BusinessUser[] findByTenant(TenantId tenantId);
  BusinessUser* findByUsername(SystemInstanceId systemId, string username);
  BusinessUser* findByEmail(SystemInstanceId systemId, string email);
  // void save(BusinessUser user);
  // void update(BusinessUser user);
  // void remove(BusinessUserId id);
}

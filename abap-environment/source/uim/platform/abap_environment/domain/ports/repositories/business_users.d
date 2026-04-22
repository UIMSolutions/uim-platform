/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.business_users;

import uim.platform.abap_environment.domain.entities.business_user;
import uim.platform.abap_environment.domain.types;

/// Port: outgoing - business user persistence.
interface BusinessUserRepository : ITenantRepository!(BusinessUser, BusinessUserId) {

  bool existsByUsername(SystemInstanceId systemId, string username);
  BusinessUser findByUsername(SystemInstanceId systemId, string username);
  void removeByUsername(SystemInstanceId systemId, string username);
  
  bool existsByEmail(SystemInstanceId systemId, string email);
  BusinessUser findByEmail(SystemInstanceId systemId, string email);
  void removeByEmail(SystemInstanceId systemId, string email);

  size_t countBySystem(SystemInstanceId systemId);
  BusinessUser[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

}

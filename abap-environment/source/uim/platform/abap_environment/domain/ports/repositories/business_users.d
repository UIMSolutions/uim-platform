/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.business_users;
// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - business user persistence.
interface BusinessUserRepository : ITenantRepository!(BusinessUser, BusinessUserId) {

  bool existsByUsername(TenantId tenantId, SystemInstanceId systemId, string username);
  BusinessUser findByUsername(TenantId tenantId, SystemInstanceId systemId, string username);
  void removeByUsername(TenantId tenantId, SystemInstanceId systemId, string username);
  
  bool existsByEmail(TenantId tenantId, SystemInstanceId systemId, string email);
  BusinessUser findByEmail(TenantId tenantId, SystemInstanceId systemId, string email);
  void removeByEmail(TenantId tenantId, SystemInstanceId systemId, string email);

  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId);
  BusinessUser[] findBySystem(TenantId tenantId, SystemInstanceId systemId);
  void removeBySystem(TenantId tenantId, SystemInstanceId systemId);

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.user;

// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — user persistence.
interface UserRepository : ITenantRepository!(User, UserId) {

  bool existsByEmail(TenantId tenantId, string email);
  User findByEmail(TenantId tenantId, string email);
  void removeByEmail(TenantId tenantId, string email);

  bool existsByUserName(TenantId tenantId, string userName);
  User findByUserName(TenantId tenantId, string userName);
  void removeByUserName(TenantId tenantId, string userName);

  size_t countByGroupId(GroupId groupId);
  User[] findByGroupId(GroupId groupId);
  void removeByGroupId(GroupId groupId);

}

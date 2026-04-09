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
interface UserRepository {
  User findById(UserId id);
  User findByEmail(TenantId tenantId, string email);
  User findByUserName(TenantId tenantId, string userName);
  User[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  User[] findByGroupId(GroupId groupId);
  void save(User user);
  void update(User user);
  void remove(UserId id);
  usize_t countByTenant(TenantId tenantId);
}

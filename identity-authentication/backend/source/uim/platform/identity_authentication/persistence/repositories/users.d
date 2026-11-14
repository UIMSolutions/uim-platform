/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.users;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// User repository on a tenant store (memory or JSON snapshots).
/// E-mail addresses and user names are compared case-insensitively.
class UserRepository : TenantRepository!(IAUser, UserId), IUserRepository {
  mixin TenantRepositoryTemplate!(UserRepository, IAUser, UserId);

  bool existsByEmail(TenantId tenantId, string email) {
    return !findByEmail(tenantId, email).isNull;
  }

  IAUser findByEmail(TenantId tenantId, string email) {
    foreach (u; findByTenant(tenantId))
      if (sicmp(u.email, email) == 0)
        return u;
    return IAUser.init;
  }

  void removeByEmail(TenantId tenantId, string email) {
    remove(findByEmail(tenantId, email));
  }

  bool existsByUserName(TenantId tenantId, string userName) {
    return !findByUserName(tenantId, userName).isNull;
  }

  IAUser findByUserName(TenantId tenantId, string userName) {
    foreach (u; findByTenant(tenantId))
      if (sicmp(u.userName, userName) == 0)
        return u;
    return IAUser.init;
  }

  void removeByUserName(TenantId tenantId, string userName) {
    remove(findByUserName(tenantId, userName));
  }

  size_t countByGroupId(TenantId tenantId, GroupId groupId) {
    return countByTenant(tenantId, (IAUser u) => u.isMemberOf(groupId));
  }

  IAUser[] findByGroupId(TenantId tenantId, GroupId groupId) {
    return findByTenant(tenantId).filter!(u => u.isMemberOf(groupId)).array;
  }

  void removeByGroupId(TenantId tenantId, GroupId groupId) {
    remove(findByGroupId(tenantId, groupId));
  }

  IAUser[] findByStatus(TenantId tenantId, UserStatus status) {
    return findByTenant(tenantId).filter!(u => u.status == status).array;
  }
}
///
unittest {
  assert(tenantRepositoryTest(new UserRepository()));

  auto repo = new UserRepository();
  auto t = TenantId("t1");
  auto u = IAUser(t);
  u.email = "jane@example.com";
  u.userName = "Jane";
  u.groupIds = [GroupId("g1")];
  repo.save(u);
  assert(repo.existsByEmail(t, "JANE@example.com"));
  assert(repo.findByUserName(t, "jane").id == u.id);
  assert(repo.countByGroupId(t, GroupId("g1")) == 1);
  assert(repo.findByStatus(t, UserStatus.locked).length == 0);
  assert(!repo.existsByEmail(TenantId("other"), "jane@example.com"));
}

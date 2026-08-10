/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.repositories.tenant_users;

import uim.platform.datasphere_composer;

mixin(ShowModule!());


@safe:
class TenantUserRepository
    : TenantRepository!(TenantUser, TenantUserId),
      ITenantUserRepository {

  bool existsByEmail(TenantId tenantId, string email) {
    return findByTenant(tenantId).any!(user => user.email == email);
  }

  TenantUser findByEmail(TenantId tenantId, string email) {
    foreach(user; findByTenant(tenantId))
      if (user.email == email) return user;

    return TenantUser.init;
  }

  void removeByEmail(TenantId tenantId, string email) {
    findByEmail(tenantId, email).each!(e => remove(e));
  }

  size_t countByRule(TenantId tenantId, TenantUserRole role) {
    return findByRule(tenantId, role).length;
  }

  TenantUser[] filterByRole(TenantUser[] users, TenantUserRole role) {
    return users.filter!(user => user.role == role).array;
  }

  TenantUser[] findByRole(TenantId tenantId, TenantUserRole role) {
    return filterByRole(findByTenant(tenantId), role);
  }

  void removeByRole(TenantId tenantId, TenantUserRole role) {
    findByRule(tenantId, role).each!(e => remove(e));
  }

}

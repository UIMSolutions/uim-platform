/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.tenant_user;

import uim.platform.datasphere_composer;
mixin(ShowModule!());

@safe:

/// A user/administrator registered for a tenant's Data Composer.
struct TenantUser {
  mixin TenantEntity!(TenantUserId);

  string email;
  string firstName;
  string lastName;
  TenantUserRole role;
  bool   active;
  long   lastLoginAt;
  string externalUserId; /// Identity from IdP

  Json toJson() const {
    return entityToJson()
      .set("email", email)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("role", role.to!string)
      .set("active", active)
      .set("lastLoginAt", lastLoginAt)
      .set("externalUserId", externalUserId);
  }
}

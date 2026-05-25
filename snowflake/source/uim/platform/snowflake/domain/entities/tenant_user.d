/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.tenant_user;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct SnowflakeTenantUser {
  mixin TenantEntity!(SnowflakeTenantUserId);

  string          email;
  string          firstName;
  string          lastName;
  TenantUserRole  role;
  bool            active;
  string          externalUserId;
  string          lastLoginAt;

  Json toJson() const {
    return entityToJson()
      .set("email",          Json(email))
      .set("firstName",      Json(firstName))
      .set("lastName",       Json(lastName))
      .set("role",           Json(cast(string) role))
      .set("active",         Json(active))
      .set("externalUserId", Json(externalUserId))
      .set("lastLoginAt",    Json(lastLoginAt));
  }
}

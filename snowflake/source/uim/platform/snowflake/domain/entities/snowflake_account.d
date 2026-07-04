/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.snowflake_account;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct SnowflakeAccount {
  mixin TenantEntity!(SnowflakeAccountId);

  string          name;
  string          region;
  AccountStatus   status;
  string          adminEmail;
  string          adminFirstName;
  string          adminLastName;
  string          organizationUrl;
  string          activationUrl;
  long          activatedAt;
  string          entitlementSystemId;
  string[string]  metadata;

  Json toJson() const {
    return entityToJson()
      .set("name",               Json(name))
      .set("region",             Json(region))
      .set("status",             Json(cast(string) status))
      .set("adminEmail",         Json(adminEmail))
      .set("adminFirstName",     Json(adminFirstName))
      .set("adminLastName",      Json(adminLastName))
      .set("organizationUrl",    Json(organizationUrl))
      .set("activationUrl",      Json(activationUrl))
      .set("activatedAt",        Json(activatedAt))
      .set("entitlementSystemId", Json(entitlementSystemId))
      .set("metadata",           jsonKeyValuePairs(metadata));
  }
}

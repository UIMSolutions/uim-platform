/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.snowflake_role;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct SnowflakeRole {
  mixin TenantEntity!(SnowflakeRoleId);

  SnowflakeAccountId accountId;
  string             name;
  string             description;
  string[]           privileges;
  bool               active;
  string[string]     metadata;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (p; privileges) arr ~= Json(p);
    return entityToJson()
      .set("accountId",   Json(accountId.value))
      .set("name",        Json(name))
      .set("description", Json(description))
      .set("privileges",  arr)
      .set("active",      Json(active))
      .set("metadata",    jsonKeyValuePairs(metadata));
  }
}

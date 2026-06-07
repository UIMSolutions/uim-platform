/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.snowflake_database;

import uim.platform.snowflake;

// mixin(ShowModule!());

@safe:
struct SnowflakeDatabase {
  mixin TenantEntity!(SnowflakeDatabaseId);

  SnowflakeAccountId accountId;
  string             name;
  int                retentionDays;
  DatabaseStatus     status;
  string             comment;
  string[string]     metadata;

  Json toJson() const {
    return entityToJson()
      .set("accountId",     Json(accountId.value))
      .set("name",          Json(name))
      .set("retentionDays", Json(retentionDays))
      .set("status",        Json(cast(string) status))
      .set("comment",       Json(comment))
      .set("metadata",      jsonKeyValuePairs(metadata));
  }
}

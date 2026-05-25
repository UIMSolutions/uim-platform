/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.snowflake_warehouse;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct SnowflakeWarehouse {
  mixin TenantEntity!(SnowflakeWarehouseId);

  SnowflakeAccountId accountId;
  string             name;
  WarehouseSize      size;
  WarehouseStatus    status;
  int                autoSuspend;  // seconds before auto-suspend (0 = disabled)
  bool               autoResume;
  string             comment;
  string[string]     metadata;

  Json toJson() const {
    return entityToJson()
      .set("accountId",   Json(accountId.value))
      .set("name",        Json(name))
      .set("size",        Json(cast(string) size))
      .set("status",      Json(cast(string) status))
      .set("autoSuspend", Json(autoSuspend))
      .set("autoResume",  Json(autoResume))
      .set("comment",     Json(comment))
      .set("metadata",    jsonKeyValuePairs(metadata));
  }
}

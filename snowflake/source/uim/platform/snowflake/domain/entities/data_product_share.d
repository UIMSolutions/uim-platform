/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.data_product_share;

import uim.platform.snowflake;

// mixin(ShowModule!());

@safe:
struct DataProductShare {
  mixin TenantEntity!(DataProductShareId);

  SnowflakeAccountId  accountId;
  ZerocopyConnectorId connectorId;
  string              dataProductId;
  string              shareName;
  ShareStatus         status;
  long              sharedAt;
  long              lastSyncAt;
  int                 tableCount;
  string              comment;
  string[string]      metadata;

  Json toJson() const {
    return entityToJson()
      .set("accountId",     Json(accountId.value))
      .set("connectorId",   Json(connectorId.value))
      .set("dataProductId", Json(dataProductId))
      .set("shareName",     Json(shareName))
      .set("status",        Json(cast(string) status))
      .set("sharedAt",      Json(sharedAt))
      .set("lastSyncAt",    Json(lastSyncAt))
      .set("tableCount",    Json(tableCount))
      .set("comment",       Json(comment))
      .set("metadata",      jsonKeyValuePairs(metadata));
  }
}

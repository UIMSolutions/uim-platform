/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.zerocopy_connector;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct ZerocopyConnector {
  mixin TenantEntity!(ZerocopyConnectorId);

  SnowflakeAccountId accountId;
  string             name;
  ConnectorStatus    status;
  string             invitationLink;
  string             bdcTenantId;
  long             enrolledAt;
  string             description;
  string[string]     metadata;

  Json toJson() const {
    return entityToJson()
      .set("accountId",      Json(accountId.value))
      .set("name",           Json(name))
      .set("status",         Json(cast(string) status))
      .set("invitationLink", Json(invitationLink))
      .set("bdcTenantId",    Json(bdcTenantId))
      .set("enrolledAt",     Json(enrolledAt))
      .set("description",    Json(description))
      .set("metadata",       jsonKeyValuePairs(metadata));
  }
}

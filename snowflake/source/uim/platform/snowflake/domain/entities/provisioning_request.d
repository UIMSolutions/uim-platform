/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.entities.provisioning_request;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct ProvisioningRequest {
  mixin TenantEntity!(ProvisioningRequestId);

  string              requestedBy;
  string              accountName;
  string              region;
  string              adminEmail;
  string              adminFirstName;
  string              adminLastName;
  ProvisioningStatus  status;
  string              resultAccountId;
  string              errorMessage;
  long              completedAt;
  string[string]      metadata;

  Json toJson() const {
    return entityToJson()
      .set("requestedBy",     Json(requestedBy))
      .set("accountName",     Json(accountName))
      .set("region",          Json(region))
      .set("adminEmail",      Json(adminEmail))
      .set("adminFirstName",  Json(adminFirstName))
      .set("adminLastName",   Json(adminLastName))
      .set("status",          Json(cast(string) status))
      .set("resultAccountId", Json(resultAccountId))
      .set("errorMessage",    Json(errorMessage))
      .set("completedAt",     Json(completedAt))
      .set("metadata",        jsonKeyValuePairs(metadata));
  }
}

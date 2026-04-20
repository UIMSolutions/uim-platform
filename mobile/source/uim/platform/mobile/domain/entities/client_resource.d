/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.client_resource;

import uim.platform.mobile.domain.types;

struct ClientResource {
  mixin TenantEntity!(ClientResourceId);

  MobileAppId appId;
  string name;
  string description;
  ClientResourceType type;
  string contentType;       // MIME type
  string data;              // base64-encoded content
  long sizeBytes;
  long version_;
  
  Json toJson() const {
    auto j = entityToJson
      .set("appId", appId.value)
      .set("name", name)
      .set("description", description)
      .set("type", type.toString())
      .set("contentType", contentType)
      .set("data", data)
      .set("sizeBytes", sizeBytes)
      .set("version", version_);

    return j;
  }
}

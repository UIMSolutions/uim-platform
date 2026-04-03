/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.client_resource;

import uim.platform.mobile.domain.types;

struct ClientResource {
  ClientResourceId id;
  TenantId tenantId;
  MobileAppId appId;
  string name;
  string description;
  ClientResourceType type;
  string contentType;       // MIME type
  string data;              // base64-encoded content
  long sizeBytes;
  long version_;
  long createdAt;
  long updatedAt;
  string createdBy;
}

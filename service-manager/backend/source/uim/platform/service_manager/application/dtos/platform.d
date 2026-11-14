/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct RegisterPlatformRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string name;
  string description;
  string type;
  string region;
  string subaccountId;
  string brokerUrl;
  string credentials;
}

struct UpdatePlatformRequest {
  TenantId tenantId;
  UserId actor;
  PlatformId id;

  Patch!string name;
  Patch!string description;
  Patch!string type;
  Patch!string status;
  Patch!string region;
  Patch!string subaccountId;
  Patch!string brokerUrl;
  Patch!string credentials;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.message_client;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct CreateMessageClientRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string serviceId;
  string name;
  string description;
  string protocol;
  string clientId;
  string clientSecret;
  string tokenUrl;
  string permittedNamespace;
}

struct UpdateMessageClientRequest {
  TenantId tenantId;
  UserId actor;
  MessageClientId id;

  Patch!(string) name;
  Patch!(string) description;
  Patch!(string) status;
  Patch!(string) protocol;
  Patch!(string) clientSecret;
  Patch!(string) tokenUrl;
  Patch!(string) permittedNamespace;
}

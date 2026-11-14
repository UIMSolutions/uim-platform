/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct CreateWebhookRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string queueId;
  string name;
  string description;
  string url;
  string headers;
  bool exemptHandshake;
  string authenticationType;
  string credentials;
  string tokenUrl;
  string clientId;
  string deliveryMode;
  int batchSize;
}

struct UpdateWebhookRequest {
  TenantId tenantId;
  UserId actor;
  WebhookId id;

  Patch!(string) name;
  Patch!(string) description;
  Patch!(string) status;
  Patch!(string) url;
  Patch!(string) headers;
  Patch!(bool) exemptHandshake;
  Patch!(string) authenticationType;
  Patch!(string) credentials;
  Patch!(string) tokenUrl;
  Patch!(string) clientId;
  Patch!(string) deliveryMode;
  Patch!(int) batchSize;
}

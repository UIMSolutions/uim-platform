/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_webhooks;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageWebhooks {
  Webhook[] listWebhooks(TenantId tenantId);
  Webhook getWebhook(TenantId tenantId, WebhookId id);
  Webhook createWebhook(CreateWebhookRequest request);
  Webhook updateWebhook(UpdateWebhookRequest request);
  /// Stops push delivery.
  void deleteWebhook(TenantId tenantId, WebhookId id);
}

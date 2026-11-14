/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port: push queued messages to webhooks (worker, CLI, GUI, Fiori).
module uim.platform.events.ports.messaging.deliver_webhooks;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IDeliverWebhooks {
  /// One delivery run of a webhook.
  DeliveryResult deliver(TenantId tenantId, WebhookId id, UserId actor);
  /// One delivery run of every active webhook of the tenant.
  DeliveryResult[] deliverAll(TenantId tenantId, UserId actor);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.enumerations.webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

enum WebhookStatus : string {
  active = "active",
  paused = "paused",
  failed = "failed"
}

enum WebhookAuthType : string {
  none = "none",
  basic = "basic",
  oauth2 = "oauth2",
  apiKey = "apiKey"
}

/// atLeastOnce (QoS 1): a message stays queued until the endpoint returns 2xx.
/// atMostOnce (QoS 0): a message is removed after the first attempt.
enum WebhookDeliveryMode : string {
  atLeastOnce = "atLeastOnce",
  atMostOnce = "atMostOnce"
}

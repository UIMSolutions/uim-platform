/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.statistics;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct EventsStatistics {
  string tenantId;
  size_t services;
  size_t activeServices;
  size_t clients;
  size_t queues;
  size_t subscriptions;
  size_t webhooks;
  size_t failingWebhooks; /// webhooks whose last delivery failed
  size_t channels;
  size_t bindings;
  size_t queuedMessages;
  size_t deadLetteredMessages;
  long deliveredMessages; /// total of all webhooks
}

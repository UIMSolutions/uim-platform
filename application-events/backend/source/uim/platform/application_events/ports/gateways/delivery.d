/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port of the push delivery: hand a CloudEvent to the webhook of
/// a channel (adapters: simulated, HTTP).
module uim.platform.application_events.ports.gateways.delivery;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct DeliveryOutcome {
  bool success;
  int statusCode; /// HTTP status (0 = no answer)
  string message; /// error text or a short confirmation
}

interface IDeliveryGateway {
  /// "simulate" or "http" (diagnostics).
  string mode();
  /// One delivery attempt; never throws for unreachable endpoints.
  DeliveryOutcome deliver(const EventChannel channel, const EventMessage message);
}

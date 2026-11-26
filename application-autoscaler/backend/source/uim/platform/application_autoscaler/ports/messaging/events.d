/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound business events (binding.created, policy.attached,
/// scaling.succeeded, scaling.failed, metrics.purged, login.failed, …) for
/// event brokers or the audit log. Events carry ids and states, never
/// credentials.
module uim.platform.application_autoscaler.ports.messaging.events;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IAasEventPublisher {
  /// type: e.g. "scaling.succeeded"; subject: the resource id.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IAasEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

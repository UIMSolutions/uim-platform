/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound lifecycle events (execution started/completed, deployment
/// running/stopped, schedule fired, …) for event brokers or audit logs.
module uim.platform.ai_core.ports.messaging.events;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

interface IAiCoreEventPublisher {
  /// type: e.g. "execution.completed"; subject: the resource key.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IAiCoreEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

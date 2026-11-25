/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound business events (job.created, schedule.fired, run.completed,
/// run.failed, run.deadLettered, login.failed, …) for event brokers, alert
/// notifications or the audit log. Events carry ids, never payloads.
module uim.platform.job_scheduling.ports.messaging.events;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IJsEventPublisher {
  /// type: e.g. "run.deadLettered"; subject: the resource id.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IJsEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

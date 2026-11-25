/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound business events (workflow.started, task.completed,
/// automation.failed, system.tested, login.failed, …) for event brokers or
/// the audit log. Events carry ids and states, never credentials.
module uim.platform.integration_automation.ports.messaging.events;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

interface IIaEventPublisher {
  /// type: e.g. "workflow.completed"; subject: the resource id.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IIaEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

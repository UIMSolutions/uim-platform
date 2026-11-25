/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound business events (document.uploaded, document.extracted,
/// document.confirmed, field.corrected, schema.activated, training.completed,
/// login.failed, …) for event brokers or the audit log. Events carry ids
/// and states, never extracted values or credentials.
module uim.platform.document_ai.ports.messaging.events;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IDaiEventPublisher {
  /// type: e.g. "document.confirmed"; subject: the resource id.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IDaiEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

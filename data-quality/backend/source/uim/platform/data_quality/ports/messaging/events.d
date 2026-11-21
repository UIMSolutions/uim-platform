/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound business events (dataset.validated, record.created,
/// duplicates.detected, cleansingJob.completed, …) for event brokers or
/// audit logs.
module uim.platform.data_quality.ports.messaging.events;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IDqEventPublisher {
  /// type: e.g. "dataset.validated"; subject: the resource key.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IDqEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

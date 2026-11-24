/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound business events (dataSubject.blocked, dataSubject.destroyed,
/// deletionRequest.rejected, archivingJob.completed, login.failed, …) for
/// event brokers or the audit log. Events never carry personal data —
/// only ids.
module uim.platform.data_retention.ports.messaging.events;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IDrEventPublisher {
  /// type: e.g. "dataSubject.blocked"; subject: the resource id.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IDrEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

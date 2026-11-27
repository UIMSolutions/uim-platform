/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound audit trail of the service itself (space.created, connection.validated,
/// run.failed, login.failed, …) for the audit log or an external broker.
/// Entries carry ids and states, never credentials or data.
module uim.platform.datasphere.ports.messaging.audit;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface IAuditTrail {
  /// type: e.g. "message.deadLettered"; subject: the resource id.
  void record(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all entries.
class NullAuditTrail : IAuditTrail {
  void record(string type, TenantId t, string subject, Json data) nothrow {
  }
}

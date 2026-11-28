/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound audit trail of the service (connection.validated,
/// execution.stopped, login.failed, user.created, …): written to the
/// structured log and the persistent audit log of the administration.
/// Entries carry ids, states and field names — never credentials or prompt
/// contents.
module uim.platform.ai_launchpad.ports.messaging.audit;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IAuditTrail {
  /// type: e.g. "execution.stopped"; actor: who; subject: the resource id.
  void record(string type, TenantId t, UserId actor, string subject, Json data) nothrow;
}

/// Discards all entries.
class NullAuditTrail : IAuditTrail {
  void record(string type, TenantId t, UserId actor, string subject, Json data) nothrow {
  }
}

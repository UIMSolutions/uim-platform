/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the audit log (administration → logging).
module uim.platform.ai_launchpad.ports.usecases.logging;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IAuditLog {
  /// All entries of the tenant (newest first).
  LogEntry[] list(TenantId t);
  LogEntry get(TenantId t, LogEntryId id);
  /// Remove the entries older than the retention; returns the count.
  PurgeResult purge(TenantId t, UserId actor);
}

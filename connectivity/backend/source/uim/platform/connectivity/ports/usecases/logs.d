/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.usecases.logs;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// The connectivity event log. Entries are immutable: `create` records an
/// external event (e.g. reported by a Cloud Connector), `update` is refused.
interface IManageLogsUseCase : IManageResource!(ConnectivityLogEntry, LogEntryId,
    CreateLogEntryRequest, UpdateLogEntryRequest) {
  ConnectivityLogEntry[] bySource(TenantId tenantId, string sourceId);
  /// Remove entries that occurred before `before` (std time); returns the number removed.
  size_t purge(TenantId tenantId, long before, UserId actor);
}

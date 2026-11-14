/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.logs;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: the connectivity event log (append-only).
class ManageLogsUseCase
  : ResourceUseCase!(ConnectivityLogEntry, LogEntryId, CreateLogEntryRequest, UpdateLogEntryRequest),
  IManageLogsUseCase {

  this(ConnectivityRepositories repos, EventRecorder events) {
    super(repos, repos.logs, events, "Log entry", "connectivity.log");
  }

  override protected ConnectivityLogEntry build(CreateLogEntryRequest r) {
    auto e = ConnectivityLogEntry(r.tenantId);
    assignMatching(e, r.spec);
    validate(e.message.strip.length > 0, "Log message is required");
    validate(e.remotePort >= 0 && e.remotePort <= 65_535, "Remote port must be between 0 and 65535");
    if (e.occurredAt == 0)
      e.occurredAt = e.createdAt;
    e.name = enumText(e.eventType) ~ (e.sourceName.length > 0 ? " · " ~ e.sourceName : "");
    return e;
  }

  override protected void apply(ref ConnectivityLogEntry e, LogEntrySpec spec) {
    throw new ConnectivityConflictException("Log entries are immutable");
  }

  ConnectivityLogEntry[] bySource(TenantId tenantId, string sourceId) {
    return repos.logs.findBySource(tenantId, sourceId);
  }

  size_t purge(TenantId tenantId, long before, UserId actor) {
    auto old = repos.logs.findByTenant(tenantId).filter!(e => e.occurredAt < before).array;
    if (old.length > 0)
      repos.logs.remove(old);
    auto payload = Json.emptyObject;
    payload["tenantId"] = tenantId.value;
    payload["removed"] = old.length;
    events.publish(topic ~ ".purged", payload);
    return old.length;
  }
}

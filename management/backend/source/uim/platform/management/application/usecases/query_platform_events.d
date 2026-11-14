/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.query_platform_events;

import core.time : days;
import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: query platform events for audit and monitoring, and prune old ones.
class QueryEnvironmentEventsUseCase : IQueryEnvironmentEventsUseCase, IPruneEventsUseCase {
  protected IEnvironmentEventRepository repo;

  this(IEnvironmentEventRepository repo) {
    this.repo = repo;
  }

  EnvironmentEvent getEvent(TenantId tenantId, EnvironmentEventId id) {
    return repo.findById(tenantId, id);
  }

  EnvironmentEvent[] listEvents(TenantId tenantId) {
    return newestFirst(repo.findByTenant(tenantId));
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId) {
    return newestFirst(repo.findByGlobalAccount(tenantId, gaId));
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, SubaccountId subId) {
    return newestFirst(repo.findBySubaccount(tenantId, subId));
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, EnvironmentEventCategory category) {
    return newestFirst(repo.findByCategory(tenantId, gaId, category));
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, EnvironmentEventSeverity severity) {
    return newestFirst(repo.findBySeverity(tenantId, gaId, severity));
  }

  EnvironmentEvent[] listSince(TenantId tenantId, GlobalAccountId gaId, long sinceTimestamp) {
    return newestFirst(repo.findSince(tenantId, gaId, sinceTimestamp));
  }

  EnvironmentEvent[] queryEvents(QueryEventsRequest q) {
    EnvironmentEventCategory category;
    bool byCategory = q.category.length > 0 && tryParseEnum!EnvironmentEventCategory(q.category, category);
    EnvironmentEventSeverity minSeverity;
    bool bySeverity = q.severity.length > 0 && tryParseEnum!EnvironmentEventSeverity(q.severity, minSeverity);

    EnvironmentEvent[] result;
    foreach (e; newestFirst(repo.findByTenant(q.tenantId))) {
      if (!q.globalAccountId.isEmpty && e.globalAccountId != q.globalAccountId)
        continue;
      if (!q.subaccountId.isEmpty && e.subaccountId != q.subaccountId)
        continue;
      if (!q.directoryId.isEmpty && e.directoryId != q.directoryId)
        continue;
      if (byCategory && e.category != category)
        continue;
      if (bySeverity && e.severity < minSeverity)
        continue;
      if (q.sinceTimestamp > 0 && e.timestamp < q.sinceTimestamp)
        continue;
      result ~= e;
      if (q.limit > 0 && result.length >= q.limit)
        break;
    }
    return result;
  }

  UsecaseResult pruneEvents(TenantId tenantId, int retentionDays) {
    if (retentionDays <= 0)
      return invalid("Retention days must be greater than zero");
    auto cutoff = Clock.currStdTime - retentionDays.days.total!"hnsecs";
    auto old = repo.findByTenant(tenantId).filter!(e => e.timestamp < cutoff).array;
    if (old.length > 0)
      repo.remove(old);
    auto r = ok(tenantId.value, old.length.to!string ~ " event(s) older than " ~ retentionDays.to!string ~ " days removed");
    r.data = Json.emptyObject.set("removed", old.length).set("cutoff", cutoff).set("retentionDays", retentionDays);
    return r;
  }

  protected static EnvironmentEvent[] newestFirst(EnvironmentEvent[] events) {
    events.sort!((a, b) => a.timestamp > b.timestamp);
    return events;
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.ports.usecases.platform_events;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Driving port: query and housekeep platform events for audit and monitoring.
interface IQueryEnvironmentEventsUseCase {
  EnvironmentEvent getEvent(TenantId tenantId, EnvironmentEventId id);
  EnvironmentEvent[] listEvents(TenantId tenantId);
  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId);
  EnvironmentEvent[] listEvents(TenantId tenantId, SubaccountId subId);
  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, EnvironmentEventCategory category);
  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, EnvironmentEventSeverity severity);
  EnvironmentEvent[] listSince(TenantId tenantId, GlobalAccountId gaId, long sinceTimestamp);
  /// Filtered query (all filters optional); newest first.
  EnvironmentEvent[] queryEvents(QueryEventsRequest request);
}

/// Driving port: remove platform events older than a retention period.
interface IPruneEventsUseCase {
  /// Removes the events of the tenant older than retentionDays. data["removed"] = count.
  UsecaseResult pruneEvents(TenantId tenantId, int retentionDays);
}

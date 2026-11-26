/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of subscriptions and their filters.
module uim.platform.application_events.ports.usecases.subscriptions;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

interface IManageSubscriptions : IManageResource!(EventSubscription, EventSubscriptionId, SubscriptionInput) {
  EventSubscription pause(TenantId t, EventSubscriptionId id, UserId actor);
  EventSubscription resume(TenantId t, EventSubscriptionId id, UserId actor);
}

interface IManageFilters : IManageResource!(EventFilter, EventFilterId, FilterInput) {
  EventFilter[] listOf(TenantId t, EventSubscriptionId subscription);
}

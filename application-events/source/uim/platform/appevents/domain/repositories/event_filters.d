/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.event_filters;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.domain.valueobjects;

@safe:

interface EventFilterRepository : ITenantRepository!(EventFilter, EventFilterId) {
    EventFilter[] findBySubscription(TenantId tenantId, EventSubscriptionId subscriptionId);
    EventFilter[] findActive(TenantId tenantId);
}

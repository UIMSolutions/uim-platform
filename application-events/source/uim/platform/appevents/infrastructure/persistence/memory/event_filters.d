/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.event_filters;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.domain.repositories.event_filters;
import uim.platform.appevents.domain.valueobjects;
import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryEventFilterRepository
    : TentRepository!(EventFilter, EventFilterId)
    , EventFilterRepository
{
    override EventFilter[] findBySubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
        return findByTenant(tenantId).filter!(f => f.subscriptionId.value == subscriptionId.value).array;
    }

    override EventFilter[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(f => f.active).array;
    }
}

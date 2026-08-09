/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.event_subscriptions;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageEventSubscriptionsUseCase {

    EventSubscription getEventSubscription(TenantId tenantId, EventSubscriptionId id);
    EventSubscription[] listEventSubscriptions(TenantId tenantId);
    EventSubscription[] listByStatus(TenantId tenantId, SubscriptionStatus status);
    CommandResult createEventSubscription(EventSubscriptionDTO dto);
    CommandResult updateEventSubscription(EventSubscriptionDTO dto);
    CommandResult deleteEventSubscription(TenantId tenantId, EventSubscriptionId id);

}


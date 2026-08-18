/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.subscriptions;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageSubscriptionsUseCase { 

    EventSubscription getSubscription(TenantId tenantId, EventSubscriptionId id);

    EventSubscription[] listSubscriptions(TenantId tenantId);

    EventSubscription[] listSubscriptions(TenantId tenantId, TopicId topicId);

    EventSubscription[] listSubscriptions(TenantId tenantId, EventApplicationId applicationId);

    UsecaseResult createSubscription(SubscriptionDTO dto);

    UsecaseResult updateSubscription(SubscriptionDTO dto);

    UsecaseResult deleteSubscription(TenantId tenantId, EventSubscriptionId id);
}


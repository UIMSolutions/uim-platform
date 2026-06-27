/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.event_subscriptions;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_subscription;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.subscription_status;

@safe:

interface EventSubscriptionRepository : ITentRepository!(EventSubscription, EventSubscriptionId) {
    EventSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status);
    EventSubscription[] findByProducerSystem(TenantId tenantId, string producerSystemId);
    EventSubscription[] findByConsumerSystem(TenantId tenantId, string consumerSystemId);
    EventSubscription[] findByFormation(TenantId tenantId, FormationId formationId);
    bool nameExists(TenantId tenantId, string name);
}

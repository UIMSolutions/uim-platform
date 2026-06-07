/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.queue_subscriptions;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

interface QueueSubscriptionRepository : ITenantRepository!(QueueSubscription, QueueSubscriptionId) {
    size_t countByQueue(TenantId tenantId, QueueId queueId);
    QueueSubscription[] findByQueue(TenantId tenantId, QueueId queueId);
    QueueSubscription[] findByService(TenantId tenantId, MessagingServiceId serviceId);
    QueueSubscription[] findByTopicPattern(TenantId tenantId, string topicPattern);
    void removeByQueue(TenantId tenantId, QueueId queueId);
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.memory.queue_subscriptions;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MemoryQueueSubscriptionRepository
    : TenantRepository!(QueueSubscription, QueueSubscriptionId), QueueSubscriptionRepository {

    size_t countByQueue(TenantId tenantId, QueueId queueId) {
        return findByQueue(tenantId, queueId).length;
    }

    QueueSubscription[] findByQueue(TenantId tenantId, QueueId queueId) {
        return findByTenant(tenantId).filter!(e => e.queueId == queueId).array;
    }

    QueueSubscription[] findByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
    }

    QueueSubscription[] findByTopicPattern(TenantId tenantId, string topicPattern) {
        return findByTenant(tenantId).filter!(e => e.topicPattern == topicPattern).array;
    }

    void removeByQueue(TenantId tenantId, QueueId queueId) {
        findByQueue(tenantId, queueId).each!(e => remove(e));
    }
}

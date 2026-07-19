/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.subscriptions;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

interface SubscriptionRepository : ITenantRepository!(EventSubscription, EventSubscriptionId) {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    EventSubscription[] findByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    void removeByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);

    size_t countByTopic(TenantId tenantId, TopicId topicId);
    EventSubscription[] findByTopic(TenantId tenantId, TopicId topicId);
    void removeByTopic(TenantId tenantId, TopicId topicId);

    size_t countByApplication(TenantId tenantId, EventApplicationId applicationId);
    EventSubscription[] findByApplication(TenantId tenantId, EventApplicationId applicationId);
    void removeByApplication(TenantId tenantId, EventApplicationId applicationId);

    size_t countByStatus(TenantId tenantId, SubscriptionStatus status);
    EventSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status);
    void removeByStatus(TenantId tenantId, SubscriptionStatus status);

}

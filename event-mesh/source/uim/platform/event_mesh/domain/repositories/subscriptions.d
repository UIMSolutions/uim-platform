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

    size_t countByBrokerService(BrokerServiceId brokerServiceId);
    EventSubscription[] findByBrokerService(BrokerServiceId brokerServiceId);
    void removeByBrokerService(BrokerServiceId brokerServiceId);

    size_t countByTopic(TopicId topicId);
    EventSubscription[] findByTopic(TopicId topicId);
    void removeByTopic(TopicId topicId);

    size_t countByApplication(EventApplicationId applicationId);
    EventSubscription[] findByApplication(EventApplicationId applicationId);
    void removeByApplication(EventApplicationId applicationId);

    size_t countByStatus(SubscriptionStatus status);
    EventSubscription[] findByStatus(SubscriptionStatus status);
    void removeByStatus(SubscriptionStatus status);

}

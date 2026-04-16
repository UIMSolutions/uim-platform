/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.subscriptions;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface SubscriptionRepository {
    bool existsById(SubscriptionId id);
    EventSubscription findById(SubscriptionId id);

    EventSubscription[] findAll();
    EventSubscription[] findByTenant(TenantId tenantId);
    EventSubscription[] findByBrokerService(BrokerServiceId brokerServiceId);
    EventSubscription[] findByTopic(TopicId topicId);
    EventSubscription[] findByApplication(EventApplicationId applicationId);
    EventSubscription[] findByStatus(SubscriptionStatus status);

    void save(EventSubscription subscription);
    void update(EventSubscription subscription);
    void remove(SubscriptionId id);
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.subscriptions;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemorySubscriptionRepository : TenantRepository!(EventSubscription, EventSubscriptionId), SubscriptionRepository {

    size_t countByBrokerService(BrokerServiceId brokerServiceId) {
        return findByBrokerService(brokerServiceId).length;
    }
    EventSubscription[] filterByBrokerService(EventSubscription[] subscriptions, BrokerServiceId brokerServiceId) { 
        return subscriptions.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }   
    EventSubscription[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return filterByBrokerService(findAll(), brokerServiceId);
    }
    void removeByBrokerService(BrokerServiceId brokerServiceId) {
        findByBrokerService(brokerServiceId).each!(e => remove(e));
    }

    size_t countByTopic(TopicId topicId) {
        return findByTopic(topicId).length;
    }
    EventSubscription[] filterByTopic(EventSubscription[] subscriptions, TopicId topicId) {
        return subscriptions.filter!(e => e.topicId == topicId).array;
    }
    EventSubscription[] findByTopic(TopicId topicId) {
        return filterByTopic(findAll(), topicId);
    }
    void removeByTopic(TopicId topicId) {
        findByTopic(topicId).each!(e => remove(e));
    }

    size_t countByApplication(EventApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }
    EventSubscription[] filterByApplication(EventSubscription[] subscriptions, EventApplicationId applicationId) {
        return subscriptions.filter!(e => e.applicationId == applicationId).array;
    }
    EventSubscription[] findByApplication(EventApplicationId applicationId) {
        return filterByApplication(findAll(), applicationId);
    }
    void removeByApplication(EventApplicationId applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }

    size_t countByStatus(SubscriptionStatus status) {
        return findByStatus(status).length;
    }
    EventSubscription[] filterByStatus(EventSubscription[] subscriptions, SubscriptionStatus status) {
        return subscriptions.filter!(e => e.status == status).array;
    } 
    EventSubscription[] findByStatus(SubscriptionStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(SubscriptionStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}

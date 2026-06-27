/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.subscriptions;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class MemorySubscriptionRepository : TentRepository!(EventSubscription, EventSubscriptionId), SubscriptionRepository {

    // #region ByBrokerService
    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId) {
        return findByBrokerService(tenantId, brokerServiceId).length;
    }
    EventSubscription[] filterByBrokerService(EventSubscription[] subscriptions, BrokerServiceId serviceId) { 
        return subscriptions.filter!(e => e.serviceId == serviceId).array;
    }   
    EventSubscription[] findByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        return filterByBrokerService(findByTenant(tenantId), serviceId);
    }
    void removeByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        findByBrokerService(tenantId, serviceId).each!(e => remove(e));
    }
    // #endregion ByBrokerService

    // #region ByTopic
    size_t countByTopic(TenantId tenantId, TopicId topicId) {
        return findByTopic(tenantId, topicId).length;
    }
    EventSubscription[] filterByTopic(EventSubscription[] subscriptions, TopicId topicId) {
        return subscriptions.filter!(e => e.topicId == topicId).array;
    }
    EventSubscription[] findByTopic(TenantId tenantId, TopicId topicId) {
        return filterByTopic(findByTenant(tenantId), topicId);
    }
    void removeByTopic(TenantId tenantId, TopicId topicId) {
        findByTopic(tenantId, topicId).each!(e => remove(e));
    }
    // #endregion ByTopic

    // #region ByApplication
    size_t countByApplication(TenantId tenantId, EventApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }
    EventSubscription[] filterByApplication(EventSubscription[] subscriptions, EventApplicationId applicationId) {
        return subscriptions.filter!(e => e.applicationId == applicationId).array;
    }
    EventSubscription[] findByApplication(TenantId tenantId, EventApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }
    void removeByApplication(TenantId tenantId, EventApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }
    // #endregion ByApplication

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, SubscriptionStatus status) {
        return findByStatus(tenantId, status).length;
    }
    EventSubscription[] filterByStatus(EventSubscription[] subscriptions, SubscriptionStatus status) {
        return subscriptions.filter!(e => e.status == status).array;
    } 
    EventSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, SubscriptionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}

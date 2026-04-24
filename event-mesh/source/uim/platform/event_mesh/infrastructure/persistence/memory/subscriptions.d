/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.subscriptions;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemorySubscriptionRepository : SubscriptionRepository {
    private EventSubscription[] store;

    bool existsById(SubscriptionId id) {
        return store.any!(e => e.id == id);
    }

    EventSubscription findById(SubscriptionId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return EventSubscription.init;
    }

    EventSubscription[] findAll() { return store; }

    EventSubscription[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    EventSubscription[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }

    EventSubscription[] findByTopic(TopicId topicId) {
        return findAll().filter!(e => e.topicId == topicId).array;
    }

    EventSubscription[] findByApplication(EventApplicationId applicationId) {
        return findAll().filter!(e => e.applicationId == applicationId).array;
    }

    EventSubscription[] findByStatus(SubscriptionStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(EventSubscription subscription) { store ~= subscription; }

    void update(EventSubscription subscription) {
        foreach (ref e; findAll)
            if (e.id == subscription.id) { e = subscription; return; }
    }

    void remove(SubscriptionId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}

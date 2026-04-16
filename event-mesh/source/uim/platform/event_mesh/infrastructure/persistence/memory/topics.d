/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryTopicRepository : TopicRepository {
    private Topic[] store;

    bool existsById(TopicId id) {
        return store.any!(e => e.id == id);
    }

    Topic findById(TopicId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Topic.init;
    }

    Topic[] findAll() { return store; }

    Topic[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Topic[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return store.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }

    Topic[] findByStatus(TopicStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(Topic topic) { store ~= topic; }

    void update(Topic topic) {
        foreach (ref e; store)
            if (e.id == topic.id) { e = topic; return; }
    }

    void remove(TopicId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}

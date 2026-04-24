/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_messages;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryEventMessageRepository : EventMessageRepository {
    private EventMessage[] store;

    bool existsById(EventMessageId id) {
        return store.any!(e => e.id == id);
    }

    EventMessage findById(EventMessageId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return EventMessage.init;
    }

    EventMessage[] findAll() { return store; }

    EventMessage[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    EventMessage[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }

    EventMessage[] findByTopic(TopicId topicId) {
        return findAll().filter!(e => e.topicId == topicId).array;
    }

    EventMessage[] findByQueue(QueueId queueId) {
        return findAll().filter!(e => e.queueId == queueId).array;
    }

    EventMessage[] findByStatus(MessageStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(EventMessage message) { store ~= message; }

    void update(EventMessage message) {
        foreach (ref e; store)
            if (e.id == message.id) { e = message; return; }
    }

    void remove(EventMessageId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.queues;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryQueueRepository : QueueRepository {
    private Queue[] store;

    bool existsById(QueueId id) {
        return store.any!(e => e.id == id);
    }

    Queue findById(QueueId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return Queue.init;
    }

    Queue[] findAll() { return store; }

    Queue[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Queue[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }

    Queue[] findByStatus(QueueStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(Queue queue) { store ~= queue; }

    void update(Queue queue) {
        foreach (ref e; findAll)
            if (e.id == queue.id) { e = queue; return; }
    }

    void remove(QueueId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}

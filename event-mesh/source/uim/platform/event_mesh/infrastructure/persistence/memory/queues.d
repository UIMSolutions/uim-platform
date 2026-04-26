/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.queues;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryQueueRepository : TenantRepository!(Queue, QueueId), QueueRepository {

    size_t countByBrokerService(BrokerServiceId brokerServiceId) {
        return findByBrokerService(brokerServiceId).length;
    }
    Queue[] filterByBrokerService(Queue[] queues, BrokerServiceId brokerServiceId) {
        return queues.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    Queue[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return filterByBrokerService(findAll(), brokerServiceId);
    }
    void removeByBrokerService(BrokerServiceId brokerServiceId) {
        findByBrokerService(brokerServiceId).each!(e => remove(e));
    }

    size_t countByStatus(QueueStatus status) {
        return findByStatus(status).length;
    }
    Queue[] filterByStatus(Queue[] queues, QueueStatus status) {
        return queues.filter!(e => e.status == status).array;
    }
    Queue[] findByStatus(QueueStatus status) {
        return filterByStatus(findAll(), status);
    }
    void removeByStatus(QueueStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}

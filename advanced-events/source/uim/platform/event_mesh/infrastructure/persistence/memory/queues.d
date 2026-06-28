/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.queues;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class MemoryQueueRepository : TenantRepository!(Queue, QueueId), QueueRepository {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        return findByBrokerService(tenantId, serviceId).length;
    }
    Queue[] filterByBrokerService(Queue[] queues, BrokerServiceId serviceId) {
        return queues.filter!(e => e.serviceId == serviceId).array;
    }
    Queue[] findByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        return filterByBrokerService(find(tenantId), serviceId);
    }
    void removeByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        findByBrokerService(tenantId, serviceId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, QueueStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Queue[] filterByStatus(Queue[] queues, QueueStatus status) {
        return queues.filter!(e => e.status == status).array;
    }
    Queue[] findByStatus(TenantId tenantId, QueueStatus status) {
        return filterByStatus(find(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, QueueStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}

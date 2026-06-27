/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_messages;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class MemoryEventMessageRepository : TenantRepository!(EventMessage, EventMessageId), EventMessageRepository {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId) {
        return findByBrokerService(tenantId, brokerServiceId).length;
    }

    EventMessage[] filterByBrokerService(EventMessage[] messages, BrokerServiceId serviceId) {
        return messages.filter!(e => e.serviceId == serviceId).array;
    }

    EventMessage[] findByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        return filterByBrokerService(findByTenant(tenantId), serviceId);
    }

    void removeByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        findByBrokerService(tenantId, serviceId).each!(e => remove(e));
    }

    size_t countByTopic(TenantId tenantId, TopicId topicId) {
        return findByTopic(tenantId, topicId).length;
    }

    EventMessage[] filterByTopic(EventMessage[] messages, TopicId topicId) {
        return messages.filter!(e => e.topicId == topicId).array;
    }

    EventMessage[] findByTopic(TenantId tenantId, TopicId topicId) {
        return filterByTopic(findByTenant(tenantId), topicId);
    }

    void removeByTopic(TenantId tenantId, TopicId topicId) {
        findByTopic(tenantId, topicId).each!(e => remove(e));
    }

    size_t countByQueue(TenantId tenantId, QueueId queueId) {
        return findByQueue(tenantId, queueId).length;
    }

    EventMessage[] filterByQueue(EventMessage[] messages, QueueId queueId) {
        return messages.filter!(e => e.queueId == queueId).array;
    }

    EventMessage[] findByQueue(TenantId tenantId, QueueId queueId) {
        return filterByQueue(findByTenant(tenantId), queueId);
    }

    void removeByQueue(TenantId tenantId, QueueId queueId) {
        findByQueue(tenantId, queueId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, MessageStatus status) {
        return findByStatus(tenantId, status).length;
    }

    EventMessage[] filterByStatus(EventMessage[] messages, MessageStatus status) {
        return messages.filter!(e => e.status == status).array;
    }

    EventMessage[] findByStatus(TenantId tenantId, MessageStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, MessageStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
}

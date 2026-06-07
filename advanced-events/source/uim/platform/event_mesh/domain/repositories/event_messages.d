/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_messages;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

interface EventMessageRepository : ITenantRepository!(EventMessage, EventMessageId) {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    EventMessage[] findByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    void removeByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);

    size_t countByTopic(TenantId tenantId, TopicId topicId);
    EventMessage[] findByTopic(TenantId tenantId, TopicId topicId);
    void removeByTopic(TenantId tenantId, TopicId topicId);

    size_t countByQueue(TenantId tenantId, QueueId queueId);
    EventMessage[] findByQueue(TenantId tenantId, QueueId queueId);
    void removeByQueue(TenantId tenantId, QueueId queueId);

    size_t countByStatus(TenantId tenantId, MessageStatus status);
    EventMessage[] findByStatus(TenantId tenantId, MessageStatus status);
    void removeByStatus(TenantId tenantId, MessageStatus status);

}

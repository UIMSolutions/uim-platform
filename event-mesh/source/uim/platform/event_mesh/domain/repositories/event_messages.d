/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_messages;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface EventMessageRepository {
    bool existsById(EventMessageId id);
    EventMessage findById(EventMessageId id);

    EventMessage[] findAll();
    EventMessage[] findByTenant(TenantId tenantId);
    EventMessage[] findByBrokerService(BrokerServiceId brokerServiceId);
    EventMessage[] findByTopic(TopicId topicId);
    EventMessage[] findByQueue(QueueId queueId);
    EventMessage[] findByStatus(MessageStatus status);

    void save(EventMessage message);
    void update(EventMessage message);
    void remove(EventMessageId id);
}

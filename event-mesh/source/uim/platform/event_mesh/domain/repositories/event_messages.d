/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_messages;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface EventMessageRepository : ITenantRepository!(EventMessage, EventMessageId) {

    size_t countByBrokerService(BrokerServiceId brokerServiceId);
    EventMessage[] findByBrokerService(BrokerServiceId brokerServiceId);
    void removeByBrokerService(BrokerServiceId brokerServiceId);

    size_t countByTopic(TopicId topicId);
    EventMessage[] findByTopic(TopicId topicId);
    void removeByTopic(TopicId topicId);

    size_t countByQueue(QueueId queueId);
    EventMessage[] findByQueue(QueueId queueId);
    void removeByQueue(QueueId queueId);

    size_t countByStatus(MessageStatus status);
    EventMessage[] findByStatus(MessageStatus status);
    void removeByStatus(MessageStatus status);

}

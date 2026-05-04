/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_messages;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryEventMessageRepository : TenantRepository!(EventMessage, EventMessageId), EventMessageRepository {

    size_t countByBrokerService(BrokerServiceId brokerServiceId) {
        return findByBrokerService(brokerServiceId).length;
    }
    EventMessage[] filterByBrokerService(EventMessage[] messages, BrokerServiceId brokerServiceId) {
        return messages.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }   
    EventMessage[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    void removeByBrokerService(BrokerServiceId brokerServiceId) {
        findByBrokerService(brokerServiceId).each!(e => remove(e));
    }

    size_t countByTopic(TopicId topicId) {
        return findByTopic(topicId).length;
    }

    EventMessage[] filterByTopic(EventMessage[] messages, TopicId topicId) {
        return messages.filter!(e => e.topicId == topicId).array;
    }

    EventMessage[] findByTopic(TopicId topicId) {
        return findAll().filter!(e => e.topicId == topicId).array;
    }
    void removeByTopic(TopicId topicId) {
        findByTopic(topicId).each!(e => remove(e));
    }


    size_t countByQueue(QueueId queueId) {
        return findByQueue(queueId).length;
    }
        EventMessage[] filterByQueue(EventMessage[] messages, QueueId queueId) {
            return messages.filter!(e => e.queueId == queueId).array;
        }
    EventMessage[] findByQueue(QueueId queueId) {
        return findAll().filter!(e => e.queueId == queueId).array;
    }
    void removeByQueue(QueueId queueId) {
        findByQueue(queueId).removeAll;
    }

     size_t countByStatus(MessageStatus status) {
        return findByStatus(status).length;
    }

        EventMessage[] filterByStatus(EventMessage[] messages, MessageStatus status) {
            return messages.filter!(e => e.status == status).array;
        }

    EventMessage[] findByStatus(MessageStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(MessageStatus status) {
        findByStatus(status).each!(e => remove(e));
    }
}

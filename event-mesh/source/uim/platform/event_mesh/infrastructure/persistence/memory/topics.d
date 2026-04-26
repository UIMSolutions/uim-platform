/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryTopicRepository : TenantRepository!(Topic, TopicId), TopicRepository {

    size_t countByBrokerService(BrokerServiceId brokerServiceId) {
        return findByBrokerService(brokerServiceId).length;
    }
    Topic[] filterByBrokerService(Topic[] topics, BrokerServiceId brokerServiceId) {
        return topics.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    Topic[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    void removeByBrokerService(BrokerServiceId brokerServiceId) {
        findByBrokerService(brokerServiceId).each!(e => remove(e));
    }

    size_t countByStatus(TopicStatus status) {
        return findByStatus(status).length;
    }
    Topic[] filterByStatus(Topic[] topics, TopicStatus status) {
        return topics.filter!(e => e.status == status).array;
    }
    Topic[] findByStatus(TopicStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(TopicStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}

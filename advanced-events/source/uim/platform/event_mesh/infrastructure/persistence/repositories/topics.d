/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.repositories.topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryTopicRepository : TenantRepository!(Topic, TopicId), TopicRepository {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        return findByBrokerService(tenantId, serviceId).length;
    }
    Topic[] filterByBrokerService(Topic[] topics, BrokerServiceId serviceId) {
        return topics.filter!(e => e.serviceId == serviceId).array;
    }
    Topic[] findByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        return filterByBrokerService(findByTenant(tenantId), serviceId);
    }
    void removeByBrokerService(TenantId tenantId, BrokerServiceId serviceId) {
        findByBrokerService(tenantId, serviceId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, TopicStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Topic[] filterByStatus(Topic[] topics, TopicStatus status) {
        return topics.filter!(e => e.status == status).array;
    }
    Topic[] findByStatus(TenantId tenantId, TopicStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, TopicStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}

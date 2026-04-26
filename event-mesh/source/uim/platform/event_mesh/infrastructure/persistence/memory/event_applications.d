/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_applications;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryEventApplicationRepository : TenantRepository!(EventApplication, EventApplicationId), EventApplicationRepository {

    size_t countByBrokerService(BrokerServiceId brokerServiceId) {
        return findByBrokerService(brokerServiceId).length;
    }
    EventApplication[] filterByBrokerService(EventApplication[] apps, BrokerServiceId brokerServiceId) {
        return apps.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    EventApplication[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    void removeByBrokerService(BrokerServiceId brokerServiceId) {
        findByBrokerService(brokerServiceId).each!(e => remove(e));
    }

    size_t countByStatus(EventApplicationStatus status) {
        return findByStatus(status).length;
    }
    EventApplication[] filterByStatus(EventApplication[] apps, EventApplicationStatus status) {
        return apps.filter!(e => e.status == status).array;
    }
    EventApplication[] findByStatus(EventApplicationStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(EventApplicationStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

    size_t countByType(EventApplicationType appType) {
        return findByType(appType).length;
    }
    EventApplication[] filterByType(EventApplication[] apps, EventApplicationType appType) {
        return apps.filter!(e => e.applicationType == appType).array;
    }
    EventApplication[] findByType(EventApplicationType appType) {
        return findAll().filter!(e => e.applicationType == appType).array;
    }
    void removeByType(EventApplicationType appType) {
        findByType(appType).each!(e => remove(e));
    }

}

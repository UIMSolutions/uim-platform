/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_applications;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class MemoryEventApplicationRepository : TenantRepository!(EventApplication, EventApplicationId), EventApplicationRepository {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId) {
        return findByBrokerService(tenantId, brokerServiceId).length;
    }
    EventApplication[] filterByBrokerService(EventApplication[] apps, BrokerServiceId brokerServiceId) {
        return apps.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }
    EventApplication[] findByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId) {
        return filterByBrokerService(find(tenantId), brokerServiceId);
    }
    void removeByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId) {
        findByBrokerService(tenantId, brokerServiceId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, EventApplicationStatus status) {
        return findByStatus(tenantId, status).length;
    }
    EventApplication[] filterByStatus(EventApplication[] apps, EventApplicationStatus status) {
        return apps.filter!(e => e.status == status).array;
    }
    EventApplication[] findByStatus(TenantId tenantId, EventApplicationStatus status) {
        return filterByStatus(find(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, EventApplicationStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByType(TenantId tenantId, EventApplicationType appType) {
        return findByType(tenantId, appType).length;
    }
    EventApplication[] filterByType(EventApplication[] apps, EventApplicationType appType) {
        return apps.filter!(e => e.applicationType == appType).array;
    }
    EventApplication[] findByType(TenantId tenantId, EventApplicationType appType) {
        return filterByType(find(tenantId), appType);
    }
    void removeByType(TenantId tenantId, EventApplicationType appType) {
        findByType(tenantId, appType).each!(e => remove(e));
    }

}

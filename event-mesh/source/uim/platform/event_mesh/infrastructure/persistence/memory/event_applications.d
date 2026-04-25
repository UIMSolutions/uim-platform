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

    EventApplication[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    EventApplication[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return findAll().filter!(e => e.brokerServiceId == brokerServiceId).array;
    }

    EventApplication[] findByStatus(EventApplicationStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    EventApplication[] findByType(EventApplicationType appType) {
        return findAll().filter!(e => e.applicationType == appType).array;
    }

}

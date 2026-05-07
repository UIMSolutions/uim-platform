/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_applications;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface EventApplicationRepository : ITenantRepository!(EventApplication, EventApplicationId) {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    EventApplication[] findByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    void removeByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);

    size_t countByStatus(TenantId tenantId, EventApplicationStatus status);
    EventApplication[] findByStatus(TenantId tenantId, EventApplicationStatus status);
    void removeByStatus(TenantId tenantId, EventApplicationStatus status);

    size_t countByType(TenantId tenantId, EventApplicationType appType);
    EventApplication[] findByType(TenantId tenantId, EventApplicationType appType);
    void removeByType(TenantId tenantId, EventApplicationType appType);

}

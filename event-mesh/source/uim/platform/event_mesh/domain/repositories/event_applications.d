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

    size_t countByBrokerService(BrokerServiceId brokerServiceId);
    EventApplication[] findByBrokerService(BrokerServiceId brokerServiceId);
    void removeByBrokerService(BrokerServiceId brokerServiceId);

    size_t countByStatus(EventApplicationStatus status);
    EventApplication[] findByStatus(EventApplicationStatus status);
    void removeByStatus(EventApplicationStatus status);

    size_t countByType(EventApplicationType appType);
    EventApplication[] findByType(EventApplicationType appType);
    void removeByType(EventApplicationType appType);

}

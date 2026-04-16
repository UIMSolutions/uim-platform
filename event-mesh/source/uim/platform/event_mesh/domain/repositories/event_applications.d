/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_applications;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface EventApplicationRepository {
    bool existsById(EventApplicationId id);
    EventApplication findById(EventApplicationId id);

    EventApplication[] findAll();
    EventApplication[] findByTenant(TenantId tenantId);
    EventApplication[] findByBrokerService(BrokerServiceId brokerServiceId);
    EventApplication[] findByStatus(EventApplicationStatus status);
    EventApplication[] findByType(EventApplicationType appType);

    void save(EventApplication application);
    void update(EventApplication application);
    void remove(EventApplicationId id);
}

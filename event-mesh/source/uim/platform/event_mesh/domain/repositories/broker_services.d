/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.broker_services;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface BrokerServiceRepository : ITenantRepository!(BrokerService, BrokerServiceId) {

    size_t countByStatus(TenantId tenantId, BrokerServiceStatus status);
    BrokerService[] findByStatus(TenantId tenantId, BrokerServiceStatus status);
    void removeByStatus(TenantId tenantId, BrokerServiceStatus status);

    size_t countByCloudProvider(TenantId tenantId, CloudProvider provider);
    BrokerService[] findByCloudProvider(TenantId tenantId, CloudProvider provider);
    void removeByCloudProvider(TenantId tenantId, CloudProvider provider);

}

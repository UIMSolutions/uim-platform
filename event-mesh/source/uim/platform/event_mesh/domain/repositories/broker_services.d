/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.broker_services;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface BrokerServiceRepository {
    bool existsById(BrokerServiceId id);
    BrokerService findById(BrokerServiceId id);

    BrokerService[] findAll();
    BrokerService[] findByTenant(TenantId tenantId);
    BrokerService[] findByStatus(BrokerServiceStatus status);
    BrokerService[] findByCloudProvider(CloudProvider provider);

    void save(BrokerService service);
    void update(BrokerService service);
    void remove(BrokerServiceId id);
}

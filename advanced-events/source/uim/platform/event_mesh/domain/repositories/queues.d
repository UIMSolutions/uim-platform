/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.queues;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

interface QueueRepository : ITenantRepository!(Queue, QueueId) {

    size_t countByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    Queue[] findByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);
    void removeByBrokerService(TenantId tenantId, BrokerServiceId brokerServiceId);

    size_t countByStatus(TenantId tenantId, QueueStatus status);
    Queue[] findByStatus(TenantId tenantId, QueueStatus status);
    void removeByStatus(TenantId tenantId, QueueStatus status);

}

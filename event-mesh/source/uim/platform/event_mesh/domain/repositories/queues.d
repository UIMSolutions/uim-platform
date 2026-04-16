/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.queues;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface QueueRepository {
    bool existsById(QueueId id);
    Queue findById(QueueId id);

    Queue[] findAll();
    Queue[] findByTenant(TenantId tenantId);
    Queue[] findByBrokerService(BrokerServiceId brokerServiceId);
    Queue[] findByStatus(QueueStatus status);

    void save(Queue queue);
    void update(Queue queue);
    void remove(QueueId id);
}

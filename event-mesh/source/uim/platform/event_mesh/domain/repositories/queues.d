/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.queues;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface QueueRepository : ITenantRepository!(Queue, QueueId) {

    size_t countByBrokerService(BrokerServiceId brokerServiceId);
    Queue[] findByBrokerService(BrokerServiceId brokerServiceId);
    void removeByBrokerService(BrokerServiceId brokerServiceId);

    size_t countByStatus(QueueStatus status);
    Queue[] findByStatus(QueueStatus status);
    void removeByStatus(QueueStatus status);

}

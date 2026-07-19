/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.queues;

import uim.platform.events;
mixin(ShowModule!());

@safe:

interface QueueRepository : ITenantRepository!(Queue, QueueId) {
    size_t countByService(TenantId tenantId, MessagingServiceId serviceId);
    Queue[] findByService(TenantId tenantId, MessagingServiceId serviceId);
    Queue[] findByStatus(TenantId tenantId, QueueStatus status);
    void removeByService(TenantId tenantId, MessagingServiceId serviceId);
}

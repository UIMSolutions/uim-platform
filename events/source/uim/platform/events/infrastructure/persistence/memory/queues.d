/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.repositories.queues;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MemoryQueueRepository
    : TenantRepository!(Queue, QueueId), QueueRepository {

    size_t countByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByService(tenantId, serviceId).length;
    }

    Queue[] findByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
    }

    Queue[] findByStatus(TenantId tenantId, QueueStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByService(TenantId tenantId, MessagingServiceId serviceId) {
        findByService(tenantId, serviceId).each!(e => remove(e));
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.memory.messaging_services;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class MemoryMessagingServiceRepository
    : TentRepository!(MessagingService, MessagingServiceId), MessagingServiceRepository {

    size_t countByStatus(TenantId tenantId, MessagingServiceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    MessagingService[] findByStatus(TenantId tenantId, MessagingServiceStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, MessagingServiceStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    MessagingService[] findByNamespace(TenantId tenantId, string namespace) {
        return findByTenant(tenantId).filter!(e => e.namespace == namespace).array;
    }
}

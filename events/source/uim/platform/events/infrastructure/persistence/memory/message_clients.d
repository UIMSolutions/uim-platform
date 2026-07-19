/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.memory.message_clients;

import uim.platform.events;
mixin(ShowModule!());

@safe:

class MemoryMessageClientRepository
    : TenantRepository!(MessageClient, MessageClientId), MessageClientRepository {

    size_t countByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByService(tenantId, serviceId).length;
    }

    MessageClient[] findByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
    }

    MessageClient[] findByStatus(TenantId tenantId, MessageClientStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }
}

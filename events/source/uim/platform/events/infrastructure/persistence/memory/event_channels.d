/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.memory.event_channels;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class MemoryEventChannelRepository
    : TenantRepository!(EventChannel, EventChannelId), EventChannelRepository {

    size_t countByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByService(tenantId, serviceId).length;
    }

    EventChannel[] findByService(TenantId tenantId, MessagingServiceId serviceId) {
        return find(tenantId).filter!(e => e.serviceId == serviceId).array;
    }

    EventChannel[] findByNamespace(TenantId tenantId, string namespace) {
        return find(tenantId).filter!(e => e.namespace == namespace).array;
    }

    EventChannel[] findByStatus(TenantId tenantId, EventChannelStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    void removeByService(TenantId tenantId, MessagingServiceId serviceId) {
        findByService(tenantId, serviceId).each!(e => remove(e));
    }
}

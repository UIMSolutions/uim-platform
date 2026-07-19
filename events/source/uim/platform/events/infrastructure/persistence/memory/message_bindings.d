/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.memory.message_bindings;

import uim.platform.events;
mixin(ShowModule!());

@safe:

class MemoryMessageBindingRepository
    : TenantRepository!(MessageBinding, MessageBindingId), MessageBindingRepository {

    size_t countByClient(TenantId tenantId, MessageClientId clientId) {
        return findByClient(tenantId, clientId).length;
    }

    MessageBinding[] findByClient(TenantId tenantId, MessageClientId clientId) {
        return findByTenant(tenantId).filter!(e => e.clientId == clientId).array;
    }

    MessageBinding[] findByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
    }

    MessageBinding[] findByQueue(TenantId tenantId, QueueId queueId) {
        return findByTenant(tenantId).filter!(e => e.queueId == queueId).array;
    }

    MessageBinding[] findByChannel(TenantId tenantId, EventChannelId channelId) {
        return findByTenant(tenantId).filter!(e => e.channelId == channelId).array;
    }

    void removeByService(TenantId tenantId, MessagingServiceId serviceId) {
        findByService(tenantId, serviceId).each!(e => remove(e));
    }
}

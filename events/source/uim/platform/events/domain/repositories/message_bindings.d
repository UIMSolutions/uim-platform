/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.message_bindings;

import uim.platform.events;
mixin(ShowModule!());

@safe:

interface MessageBindingRepository : ITenantRepository!(MessageBinding, MessageBindingId) {
    size_t countByClient(TenantId tenantId, MessageClientId clientId);
    MessageBinding[] findByClient(TenantId tenantId, MessageClientId clientId);
    MessageBinding[] findByService(TenantId tenantId, MessagingServiceId serviceId);
    MessageBinding[] findByQueue(TenantId tenantId, QueueId queueId);
    MessageBinding[] findByChannel(TenantId tenantId, EventChannelId channelId);
    void removeByService(TenantId tenantId, MessagingServiceId serviceId);
}

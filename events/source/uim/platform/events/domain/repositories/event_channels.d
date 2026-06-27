/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.event_channels;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

interface EventChannelRepository : ITenantRepository!(EventChannel, EventChannelId) {
    size_t countByService(TenantId tenantId, MessagingServiceId serviceId);
    EventChannel[] findByService(TenantId tenantId, MessagingServiceId serviceId);
    EventChannel[] findByNamespace(TenantId tenantId, string namespace);
    EventChannel[] findByStatus(TenantId tenantId, EventChannelStatus status);
    void removeByService(TenantId tenantId, MessagingServiceId serviceId);
}

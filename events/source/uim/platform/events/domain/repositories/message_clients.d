/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.message_clients;

import uim.platform.events;
mixin(ShowModule!());

@safe:

interface MessageClientRepository : ITenantRepository!(MessageClient, MessageClientId) {
    size_t countByService(TenantId tenantId, MessagingServiceId serviceId);
    MessageClient[] findByService(TenantId tenantId, MessagingServiceId serviceId);
    MessageClient[] findByStatus(TenantId tenantId, MessageClientStatus status);
}

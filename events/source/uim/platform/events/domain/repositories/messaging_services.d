/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.messaging_services;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

interface MessagingServiceRepository : ITenantRepository!(MessagingService, MessagingServiceId) {
    size_t countByStatus(TenantId tenantId, MessagingServiceStatus status);
    MessagingService[] findByStatus(TenantId tenantId, MessagingServiceStatus status);
    void removeByStatus(TenantId tenantId, MessagingServiceStatus status);
    MessagingService[] findByNamespace(TenantId tenantId, string namespace);
}

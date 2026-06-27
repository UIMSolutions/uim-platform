/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.repositories.webhooks;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

interface WebhookRepository : ITenantRepository!(Webhook, WebhookId) {
    size_t countByService(TenantId tenantId, MessagingServiceId serviceId);
    Webhook[] findByService(TenantId tenantId, MessagingServiceId serviceId);
    Webhook[] findByStatus(TenantId tenantId, WebhookStatus status);
    Webhook[] findBySubscription(TenantId tenantId, QueueSubscriptionId subscriptionId);
    void removeByService(TenantId tenantId, MessagingServiceId serviceId);
}

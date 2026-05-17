/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.persistence.memory.webhooks;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MemoryWebhookRepository
    : TenantRepository!(Webhook, WebhookId), WebhookRepository {

    size_t countByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByService(tenantId, serviceId).length;
    }

    Webhook[] findByService(TenantId tenantId, MessagingServiceId serviceId) {
        return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
    }

    Webhook[] findByStatus(TenantId tenantId, WebhookStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    Webhook[] findBySubscription(TenantId tenantId, QueueSubscriptionId subscriptionId) {
        return findByTenant(tenantId).filter!(e => e.subscriptionId == subscriptionId).array;
    }

    void removeByService(TenantId tenantId, MessagingServiceId serviceId) {
        findByService(tenantId, serviceId).each!(e => remove(e));
    }
}

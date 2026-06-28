/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.webhooks;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class ManageWebhooksUseCase {
    private WebhookRepository repo;

    this(WebhookRepository repo) { this.repo = repo; }

    Webhook getWebhook(TenantId tenantId, WebhookId id) { return repo.findById(tenantId, id); }
    Webhook[] listWebhooks(TenantId tenantId) { return repo.find(tenantId); }
    Webhook[] listByService(TenantId tenantId, MessagingServiceId serviceId) { return repo.findByService(tenantId, serviceId); }
    Webhook[] listBySubscription(TenantId tenantId, QueueSubscriptionId subscriptionId) { return repo.findBySubscription(tenantId, subscriptionId); }

    CommandResult createWebhook(WebhookDTO dto) {
        Webhook wh;
        wh.id = dto.webhookId;
        wh.tenantId = dto.tenantId;
        wh.serviceId = dto.serviceId;
        wh.subscriptionId = dto.subscriptionId;
        wh.name = dto.name;
        wh.description = dto.description;
        wh.url = dto.url;
        wh.headers = dto.headers;
        wh.exemptHandshake = dto.exemptHandshake;
        wh.credentialGrant = dto.credentialGrant;
        wh.tokenUrl = dto.tokenUrl;
        wh.clientId = dto.clientId;
        wh.pushInterval = dto.pushInterval;
        wh.maxParallelity = dto.maxParallelity;
        wh.createdBy = dto.createdBy;
        if (!EventsValidator.isValidWebhook(wh))
            return CommandResult(false, "", "Invalid webhook data");
        repo.save(wh);
        return CommandResult(true, wh.id.value, "");
    }

    CommandResult updateWebhook(WebhookDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.webhookId);
        if (existing.isNull) return CommandResult(false, "", "Webhook not found");
        if (dto.url.length > 0) existing.url = dto.url;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.headers.length > 0) existing.headers = dto.headers;
        if (dto.pushInterval.length > 0) existing.pushInterval = dto.pushInterval;
        if (dto.maxParallelity.length > 0) existing.maxParallelity = dto.maxParallelity;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteWebhook(TenantId tenantId, WebhookId id) {
        auto wh = repo.findById(tenantId, id);
        if (wh.isNull) return CommandResult(false, "", "Webhook not found");
        repo.remove(wh);
        return CommandResult(true, wh.id.value, "");
    }
}

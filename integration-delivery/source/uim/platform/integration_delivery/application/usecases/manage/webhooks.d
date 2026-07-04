/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.webhooks;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class ManageWebhooksUseCase {
    private WebhookRepository repo;

    this(WebhookRepository repo) {
        this.repo = repo;
    }

    Webhook getWebhook(TenantId tenantId, WebhookId id) {
        return repo.findById(tenantId, id);
    }

    Webhook[] listWebhooks(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Webhook[] listByRepository(TenantId tenantId, CicdRepositoryId repositoryId) {
        return repo.findByRepository(tenantId, repositoryId);
    }

    CommandResult createWebhook(WebhookDTO dto) {
        Webhook w;
        w.initEntity(dto.tenantId, dto.createdBy);
        w.id = dto.webhookId;
        w.repositoryId = dto.repositoryId;
        w.jobId = dto.jobId;
        w.secret = dto.secret;
        w.events = dto.events;
        w.callbackUrl = dto.callbackUrl;
        w.status = WebhookStatus.active;

        if (!CicdValidator.isValidWebhook(w))
            return CommandResult(false, "", "Invalid webhook data: repositoryId and jobId required");

        repo.save(w);
        return CommandResult(true, w.id.value, "");
    }

    CommandResult updateWebhook(WebhookDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.webhookId);
        if (existing.isNull)
            return CommandResult(false, "", "Webhook not found");

        if (dto.callbackUrl.length > 0) existing.callbackUrl = dto.callbackUrl;
        if (dto.secret.length > 0) existing.secret = dto.secret;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteWebhook(TenantId tenantId, WebhookId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Webhook not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}

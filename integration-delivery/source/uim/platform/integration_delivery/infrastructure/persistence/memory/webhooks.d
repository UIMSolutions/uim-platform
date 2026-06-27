/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.memory.webhooks;

import uim.platform.integration_delivery;
import std.algorithm : filter;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryWebhookRepository : TentRepository!(Webhook, WebhookId), WebhookRepository {
    Webhook[] findByRepository(TenantId tenantId, CicdRepositoryId repositoryId) {
        return findByTenant(tenantId).filter!(w => w.repositoryId == repositoryId).array;
    }

    Webhook[] findByJob(TenantId tenantId, JobId jobId) {
        return findByTenant(tenantId).filter!(w => w.jobId == jobId).array;
    }

    Webhook[] findByStatus(TenantId tenantId, WebhookStatus status) {
        return findByTenant(tenantId).filter!(w => w.status == status).array;
    }
}

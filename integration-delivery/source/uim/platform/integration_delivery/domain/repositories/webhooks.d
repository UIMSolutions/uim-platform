/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.repositories.webhooks;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

interface WebhookRepository : ITenantRepository!(Webhook, WebhookId) {
    Webhook[] findByRepository(TenantId tenantId, CicdRepositoryId repositoryId);
    Webhook[] findByJob(TenantId tenantId, JobId jobId);
    Webhook[] findByStatus(TenantId tenantId, WebhookStatus status);
}

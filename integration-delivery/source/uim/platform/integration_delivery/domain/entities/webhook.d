/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.webhook;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct Webhook {
    mixin TenantEntity!(WebhookId);

    CicdRepositoryId repositoryId;
    JobId jobId;
    string secret;
    string[] events;
    string callbackUrl;
    WebhookStatus status = WebhookStatus.active;
    long lastTriggeredAt;
    string lastTriggerResult;
    int triggerCount;

    Json toJson() const {
        return entityToJson
            .set("repositoryId", repositoryId.value)
            .set("jobId", jobId.value)
            .set("callbackUrl", callbackUrl)
            .set("status", status.to!string)
            .set("lastTriggeredAt", lastTriggeredAt)
            .set("lastTriggerResult", lastTriggerResult)
            .set("triggerCount", triggerCount);
    }
}

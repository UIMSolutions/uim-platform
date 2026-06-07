/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.stage;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

struct Stage {
    mixin TenantEntity!(StageId);

    BuildId buildId;
    string name;
    StageType stageType = StageType.buildLint;
    int order_;
    StageStatus status = StageStatus.pending;
    long startedAt;
    long finishedAt;
    long durationSeconds;
    string logs;
    string errorMessage;
    bool isOptional;

    Json toJson() const {
        return entityToJson
            .set("buildId", buildId.value)
            .set("name", name)
            .set("stageType", stageType.to!string)
            .set("order", order_)
            .set("status", status.to!string)
            .set("startedAt", startedAt)
            .set("finishedAt", finishedAt)
            .set("durationSeconds", durationSeconds)
            .set("logs", logs)
            .set("errorMessage", errorMessage)
            .set("isOptional", isOptional);
    }
}

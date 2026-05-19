/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.build;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct Build {
    mixin TenantEntity!(BuildId);

    JobId jobId;
    string commitSha;
    string branch;
    string commitMessage;
    string commitAuthor;
    BuildTrigger triggerType = BuildTrigger.manual;
    string triggerInfo;
    BuildStatus status = BuildStatus.pending;
    long startedAt;
    long finishedAt;
    long durationSeconds;
    string logUrl;
    string artifactUrl;
    string errorMessage;

    Json toJson() const {
        return entityToJson
            .set("jobId", jobId.value)
            .set("commitSha", commitSha)
            .set("branch", branch)
            .set("commitMessage", commitMessage)
            .set("commitAuthor", commitAuthor)
            .set("triggerType", triggerType.to!string)
            .set("triggerInfo", triggerInfo)
            .set("status", status.to!string)
            .set("startedAt", startedAt)
            .set("finishedAt", finishedAt)
            .set("durationSeconds", durationSeconds)
            .set("logUrl", logUrl)
            .set("artifactUrl", artifactUrl)
            .set("errorMessage", errorMessage);
    }
}

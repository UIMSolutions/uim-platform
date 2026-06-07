/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.job;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

struct Job {
    mixin TenantEntity!(JobId);

    string name;
    string description;
    PipelineId pipelineId;
    CicdRepositoryId repositoryId;
    string branch;
    TriggerMode triggerMode = TriggerMode.manual;
    string cronExpression;
    DeploymentTargetId deploymentTargetId;
    string configurationSource;
    bool notifyOnSuccess;
    bool notifyOnFailure;
    string notificationEmail;
    JobStatus status = JobStatus.active;
    long lastBuildAt;
    BuildStatus lastBuildStatus = BuildStatus.pending;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("pipelineId", pipelineId.value)
            .set("repositoryId", repositoryId.value)
            .set("branch", branch)
            .set("triggerMode", triggerMode.to!string)
            .set("cronExpression", cronExpression)
            .set("deploymentTargetId", deploymentTargetId.value)
            .set("configurationSource", configurationSource)
            .set("notifyOnSuccess", notifyOnSuccess)
            .set("notifyOnFailure", notifyOnFailure)
            .set("notificationEmail", notificationEmail)
            .set("status", status.to!string)
            .set("lastBuildAt", lastBuildAt)
            .set("lastBuildStatus", lastBuildStatus.to!string);
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Identity Provisioning Job entity (IPS).
module uim.platform.identity.domain.entities.provisioning_job;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

struct ProvisioningJob {
    mixin TenantEntity!(ProvisioningJobId);

    string name;
    string description;
    string sourceSystem;    // Source system name / ID
    string targetSystem;    // Target system name / ID
    JobType type_ = JobType.read;
    JobStatus status = JobStatus.pending;
    long startedAt;
    long finishedAt;
    int totalEntities;
    int processedEntities;
    int failedEntities;
    string errorLog;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("sourceSystem", sourceSystem)
            .set("targetSystem", targetSystem)
            .set("type", type_.to!string)
            .set("status", status.to!string)
            .set("startedAt", startedAt)
            .set("finishedAt", finishedAt)
            .set("totalEntities", totalEntities)
            .set("processedEntities", processedEntities)
            .set("failedEntities", failedEntities)
            .set("errorLog", errorLog);
        return j;
    }
}

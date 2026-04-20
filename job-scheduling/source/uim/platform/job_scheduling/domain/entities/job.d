/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.job;

// import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
struct Job {
    mixin TenantEntity!(JobId);

    string name; // e.g. "Daily Report Generation"
    string description; // e.g. "Generates daily sales report at 2 AM"
    string actionUrl; // e.g. "https://api.example.com/jobs/daily-report"
    HttpMethod httpMethod; // e.g. HttpMethod.post
    JobType type; // e.g. JobType.scheduled
    JobStatus status; // e.g. JobStatus.pending
    bool active; // e.g. true
    long startTime; // e.g. 1622520000 (Unix timestamp)
    long endTime; // e.g. 1622606400 (Unix timestamp)
    Json parameters; // JSON object with job-specific parameters

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("actionUrl", actionUrl)
            .set("httpMethod", httpMethod.toString())
            .set("type", type.toString())
            .set("status", status.toString())
            .set("active", active)
            .set("startTime", startTime)
            .set("endTime", endTime)
            .set("parameters", parameters);

        return j;
    }
}

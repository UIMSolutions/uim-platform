/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.job;

import uim.platform.job_scheduling.domain.types;

struct Job {
    JobId id;
    TenantId tenantId;
    string name;
    string description;
    string actionUrl;
    HttpMethod httpMethod;
    JobType type;
    JobStatus status;
    bool active;
    long startTime;
    long endTime;
    long createdAt;
    long modifiedAt;
}

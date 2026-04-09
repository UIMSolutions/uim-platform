/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.ports.repositories.run_logs;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.run_log;

interface RunLogRepository {
    RunLog findById(RunLogId id);
    RunLog[] findBySchedule(ScheduleId scheduleId, JobId jobtenantId, id tenantId);
    RunLog[] findByJob(JobId jobtenantId, id tenantId);
    RunLog[] findByStatus(RunStatus status, JobId jobtenantId, id tenantId);
    void save(RunLog r);
    void update(RunLog r);
    size_t countBySchedule(ScheduleId scheduleId);
}

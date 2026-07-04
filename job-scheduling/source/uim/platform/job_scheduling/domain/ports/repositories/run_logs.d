/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.ports.repositories.run_logs;


// import uim.platform.job_scheduling.domain.entities.run_log;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
interface RunLogRepository : ITenantRepository!(RunLog, RunLogId) {

    size_t countBySchedule(TenantId tenantId, ScheduleId scheduleId);
    RunLog[] findBySchedule(TenantId tenantId, ScheduleId scheduleId);
    void removeBySchedule(TenantId tenantId, ScheduleId scheduleId);

    size_t countByJob(TenantId tenantId, JobId jobId);
    RunLog[] findByJob(TenantId tenantId, JobId jobId);
    void removeByJob(TenantId tenantId, JobId jobId);

    size_t countByStatus(TenantId tenantId, RunStatus status);
    RunLog[] findByStatus(TenantId tenantId, RunStatus status);
    void removeByStatus(TenantId tenantId, RunStatus status);

}

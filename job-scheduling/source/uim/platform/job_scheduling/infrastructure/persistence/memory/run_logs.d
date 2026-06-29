/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.run_log;


// import uim.platform.job_scheduling.domain.entities.run_log;
// import uim.platform.job_scheduling.domain.ports.repositories.run_logs;


 
import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:
class MemoryRunLogRepository : TenantRepository!(RunLog, RunLogId), RunLogRepository {

    // #region ByJob
    size_t countByJob(TenantId tenantId, JobId jobId) {
        return findByJob(tenantId, jobId).length;
    }

    RunLog[] filterByJob(RunLog[] items, JobId jobId) {
        return items.filter!(r => r.jobId == jobId).array;
    }

    RunLog[] findByJob(TenantId tenantId, JobId jobId) {
        return filterByJob(findByTenant(tenantId), jobId);
    }

    void removeByJob(TenantId tenantId, JobId jobId) {
        findByJob(tenantId, jobId).each!(r => remove(r));
    }
    // #endregion ByJob

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, RunStatus status) {
        return findByStatus(tenantId, status).length;
    }

    RunLog[] filterByStatus(RunLog[] items, RunStatus status) {
        return items.filter!(r => r.status == status).array;
    }

    RunLog[] findByStatus(TenantId tenantId, RunStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, RunStatus status) {
        findByStatus(tenantId, status).each!(r => remove(r));
    }
    // #endregion ByStatus

    // #region BySchedule
    size_t countBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        return findBySchedule(tenantId, scheduleId).length;
    }

    RunLog[] filterBySchedule(RunLog[] items, ScheduleId scheduleId) {
        return items.filter!(r => r.scheduleId == scheduleId).array;
    }

    RunLog[] findBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        return filterBySchedule(findByTenant(tenantId), scheduleId);
    }

    void removeBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        findBySchedule(tenantId, scheduleId).each!(r => remove(r));
    }
    // #endregion BySchedule

}

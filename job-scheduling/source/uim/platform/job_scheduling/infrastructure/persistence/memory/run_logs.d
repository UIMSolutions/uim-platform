/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.run_log;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.run_log;
// import uim.platform.job_scheduling.domain.ports.repositories.run_logs;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class MemoryRunLogRepository : TenantRRepository!(RunLog, RunLogId), RunLogRepository {

    size_t countByStatus(TenantId tenantId, JobId jobId, RunStatus status) {
        return findByStatus(tenantId, jobId, status).length;
    }

    RunLog[] findBySchedule(TenantId tenantId, ScheduleId scheduleId, JobId jobId) {
        return findAll().filter!(r => r.scheduleId == scheduleId
            && r.jobId == jobId && r.tenantId == tenantId).array;
    }
    void removeBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        findAll().filter!(r => r.scheduleId == scheduleId && r.tenantId == tenantId)
            .each!(r => remove(r));
    }

    size_t countByJob(TenantId tenantId, JobId jobId) {
        return findByJob(tenantId, jobId).length;
    }
    RunLog[] findByJob(TenantId tenantId, JobId jobId) {
        return findAll().filter!(r => r.jobId == jobId && r.tenantId == tenantId).array;
    }
    void removeByJob(TenantId tenantId, JobId jobId) {
        findAll().filter!(r => r.jobId == jobId && r.tenantId == tenantId)
            .each!(r => remove(r));
    }

    size_t countBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        return findAll().filter!(r => r.tenantId == tenantId && r.scheduleId == scheduleId).array.length;
    }
    RunLog[] findBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        return findAll().filter!(r => r.tenantId == tenantId && r.scheduleId == scheduleId).array;
    }
    void removeBySchedule(TenantId tenantId, ScheduleId scheduleId) {
        findAll().filter!(r => r.tenantId == tenantId && r.scheduleId == scheduleId).each!(r => remove(r));
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.run_log;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.run_log;
import uim.platform.job_scheduling.domain.ports.repositories.run_logs;

import std.algorithm : filter;
import std.array : array;

class MemoryRunLogRepository : RunLogRepository {
    private RunLog[] store;

    RunLog findById(RunLogId id) {
        foreach (ref r; store) {
            if (r.id == id)
                return r;
        }
        return RunLog.init;
    }

    RunLog[] findBySchedule(ScheduleId scheduleId, JobId jobId, TenantId tenantId) {
        return store.filter!(r => r.scheduleId == scheduleId
            && r.jobId == jobId && r.tenantId == tenantId).array;
    }

    RunLog[] findByJob(JobId jobId, TenantId tenantId) {
        return store.filter!(r => r.jobId == jobId && r.tenantId == tenantId).array;
    }

    RunLog[] findByStatus(RunStatus status, JobId jobId, TenantId tenantId) {
        return store.filter!(r => r.status == status
            && r.jobId == jobId && r.tenantId == tenantId).array;
    }

    void save(RunLog r) {
        store ~= r;
    }

    void update(RunLog r) {
        foreach (ref existing; store) {
            if (existing.id == r.id) {
                existing = r;
                return;
            }
        }
    }

    long countBySchedule(ScheduleId scheduleId) {
        return cast(long) store.filter!(r => r.scheduleId == scheduleId).array.length;
    }
}

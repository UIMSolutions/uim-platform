/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.schedule;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.schedule;
import uim.platform.job_scheduling.domain.ports.repositories.schedules;

import std.algorithm : filter, canFind;
import std.array : array;
import std.uni : toLower;

class MemoryScheduleRepository : ScheduleRepository {
    private Schedule[] store;

    Schedule findById(ScheduleId id, JobId jobtenantId, id tenantId) {
        foreach (ref s; store) {
            if (s.id == id && s.jobId == jobId && s.tenantId == tenantId)
                return s;
        }
        return Schedule.init;
    }

    Schedule[] findByJob(JobId jobtenantId, id tenantId) {
        return store.filter!(s => s.jobId == jobId && s.tenantId == tenantId).array;
    }

    Schedule[] findByStatus(ScheduleStatus status, JobId jobtenantId, id tenantId) {
        return store.filter!(s => s.status == status && s.jobId == jobId && s.tenantId == tenantId).array;
    }

    Schedule[] findActiveByTenant(TenantId tenantId) {
        return store.filter!(s => s.active && s.tenantId == tenantId).array;
    }

    Schedule[] search(string query, TenantId tenantId) {
        auto q = query.toLower;
        return store.filter!(s => s.tenantId == tenantId
            && (s.description.toLower.canFind(q) || s.jobId.toLower.canFind(q))).array;
    }

    void save(Schedule s) {
        store ~= s;
    }

    void update(Schedule s) {
        foreach (ref existing; store) {
            if (existing.id == s.id && existing.jobId == s.jobId) {
                existing = s;
                return;
            }
        }
    }

    void remove(ScheduleId id, JobId jobtenantId, id tenantId) {
        store = store.filter!(s => !(s.id == id && s.jobId == jobId && s.tenantId == tenantId)).array;
    }

    void removeAllByJob(JobId jobtenantId, id tenantId) {
        store = store.filter!(s => !(s.jobId == jobId && s.tenantId == tenantId)).array;
    }

    size_t countByJob(JobId jobtenantId, id tenantId) {
        return cast(long) store.filter!(s => s.jobId == jobId && s.tenantId == tenantId).array.length;
    }
}

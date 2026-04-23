/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.schedule;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.schedule;
// import uim.platform.job_scheduling.domain.ports.repositories.schedules;

// import std.algorithm : filter, canFind;
// import std.array : array;
// import std.uni : toLower;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class MemoryScheduleRepository : TenantRepository!(Schedule, ScheduleId), ScheduleRepository {

    Schedule findById(TenantId tenantId, ScheduleId id, JobId jobId) {
        foreach (s; findByTenant(tenantId)) {
            if (s.id == id && s.jobId == jobId)
                return s;
        }
        return Schedule.init;
    }

    size_t countByStatus(TenantId tenantId, ScheduleStatus status, JobId jobId) {
        return findByStatus(tenantId, status, jobId).length;
    }

    Schedule[] findByJob(Schedule[] items, JobId jobId) {
        return items.filter!(s => s.jobId == jobId).array;
    }

    Schedule[] findByJob(TenantId tenantId, JobId jobId) {
        return findByJob(findByTenant(tenantId), jobId);
    }

    void removeByJob(TenantId tenantId, JobId jobId) {
        return findByJob(tenantId, jobId).each!(s => remove(s));
    }

    size_t countByStatus(TenantId tenantId, ScheduleStatus status, JobId jobId) {
        return findByStatus(tenantId, status, jobId).length;
    }

    Schedule[] findByStatus(TenantId tenantId, JobId jobId, ScheduleStatus status) {
        return findByJob(tenantId, jobId).filter!(s => s.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ScheduleStatus status, JobId jobId) {
        return findByStatus(tenantId, jobId, status).each!(s => remove(s));
    }

    Schedule[] findActiveByTenant(TenantId tenantId) {
        return findByTenant(tenantId).filter!(s => s.active).array;
    }

    Schedule[] search(TenantId tenantId, string query) {
        auto q = query.toLower;
        return findByTenant(tenantId).filter!(s => s.description.toLower.canFind(q) || s.jobId.toLower.canFind(q)).array;
    }

    void save(Schedule s) {
        store ~= s;
    }

    void update(Schedule s) {
        foreach (existing; findByTenant(s.tenantId)) {
            if (existing.id == s.id && existing.jobId == s.jobId) {
                existing = s;
                return;
            }
        }
    }

    void remove(ScheduleId id, TenantId tenantId, JobId jobId) {
         findByTenant(tenantId).filter!(s => !(s.id == id && s.jobId == jobId)).each!(s => remove(s));
    }

    void removeAllByJob(TenantId tenantId, JobId jobId) {
        findByTenant(tenantId).filter!(s => !(s.jobId == jobId)).each!(s => remove(s));
    }

    size_t countByJob(TenantId tenantId, JobId jobId) {
        return findByTenant(tenantId).filter!(s => s.jobId == jobId).array.length;
    }
}

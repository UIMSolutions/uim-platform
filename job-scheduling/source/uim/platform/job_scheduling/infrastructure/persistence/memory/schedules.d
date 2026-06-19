/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.schedule;


// import uim.platform.job_scheduling.domain.entities.schedule;
// import uim.platform.job_scheduling.domain.ports.repositories.schedules;


import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:
class MemoryScheduleRepository : TenantRepository!(Schedule, ScheduleId), ScheduleRepository {

    // #region ByJob
    size_t countByJob(TenantId tenantId, JobId jobId) {
        return findByJob(tenantId, jobId).length;
    }

    Schedule[] filterByJob(Schedule[] items, JobId jobId) {
        return items.filter!(s => s.jobId == jobId).array;
    }

    Schedule[] findByJob(TenantId tenantId, JobId jobId) {
        return filterByJob(findByTenant(tenantId), jobId);
    }

    void removeByJob(TenantId tenantId, JobId jobId) {
        findByJob(tenantId, jobId).each!(s => remove(s));
    }
    // #endregion ByJob

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, JobScheduleStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Schedule[] filterByStatus(Schedule[] items, JobScheduleStatus status) {
        return items.filter!(s => s.status == status).array;
    }

    Schedule[] findByStatus(TenantId tenantId, JobScheduleStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, JobScheduleStatus status) {
        findByStatus(tenantId, status).each!(s => remove(s));
    }
    // #endregion ByStatus

    // #region Active
    size_t countActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }   
    Schedule[] filterActive(Schedule[] items) {
        return items.filter!(s => s.active).array;
    }
    Schedule[] findActive(TenantId tenantId) {
        return filterActive(findByTenant(tenantId));
    }
    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(s => remove(s));
    }
    // #endregion Active

    Schedule[] search(TenantId tenantId, string query) {
        auto q = query.toLower;
        return findByTenant(tenantId).filter!(s => s.description.toLower.canFind(q) || s.jobId.toLower.canFind(
                q)).array;
    }

}

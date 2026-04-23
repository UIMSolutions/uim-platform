/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.ports.repositories.schedules;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.schedule;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
interface ScheduleRepository : ITenantRepository!(Schedule, ScheduleId) {

    size_t countByJob(TenantId tenantId, JobId jobId);
    Schedule[] findByJob(TenantId tenantId, JobId jobId);
    void removeByJob(TenantId tenantId, JobId jobId);

    size_t countByStatus(TenantId tenantId, ScheduleStatus status, JobId jobId);
    Schedule[] findByStatus(TenantId tenantId, ScheduleStatus status, JobId jobId);
    void removeByStatus(TenantId tenantId, ScheduleStatus status, JobId jobId);

    size_t countActiveByTenant(TenantId tenantId);
    Schedule[] findActiveByTenant(TenantId tenantId);
    void removeActiveByTenant(TenantId tenantId);

    Schedule[] search(TenantId tenantId, string query);
}

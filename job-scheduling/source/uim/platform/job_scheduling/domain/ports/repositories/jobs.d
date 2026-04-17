/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.ports.repositories.jobs;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.job;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
interface JobRepository : ITenantRepository!(Job, JobId) {
    // Job[] findByTenant(TenantId tenantId);

    // void save(Job j);
    // void update(Job j);
    // void remove(TenantId tenantId, JobId id);
    Job findByName(TenantId tenantId, string name);
    Job[] findByStatus(TenantId tenantId, JobStatus status);
    Job[] search(TenantId tenantId, string query);
    size_t countByTenant(TenantId tenantId);
    size_t countActiveByTenant(TenantId tenantId);
    size_t countInactiveByTenant(TenantId tenantId);
}

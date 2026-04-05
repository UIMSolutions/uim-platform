/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.ports.repositories.jobs;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.job;

interface JobRepository {
    Job findById(JobId id, TenantId tenantId);
    Job findByName(string name, TenantId tenantId);
    Job[] findByTenant(TenantId tenantId);
    Job[] findByStatus(JobStatus status, TenantId tenantId);
    Job[] search(string query, TenantId tenantId);
    void save(Job j);
    void update(Job j);
    void remove(JobId id, TenantId tenantId);
    long countByTenant(TenantId tenantId);
    long countActiveByTenant(TenantId tenantId);
    long countInactiveByTenant(TenantId tenantId);
}

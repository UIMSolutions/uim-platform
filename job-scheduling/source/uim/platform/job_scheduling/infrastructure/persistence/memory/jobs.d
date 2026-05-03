/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.job;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.job;
// import uim.platform.job_scheduling.domain.ports.repositories.jobs;

// import std.algorithm : filter, canFind;
// import std.array : array;
// import std.uni : toLower;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class MemoryJobRepository : TenantRepository!(Job, JobId), JobRepository {

    size_t countByStatus(TenantId tenantId, JobStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Job[] filterByStatus(Job[] jobs, JobStatus status) {
        return jobs.filter!(j => j.status == status).array;
    }
    Job[] findByStatus(TenantId tenantId, JobStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, JobStatus status) {
        findByStatus(tenantId, status).each!(j => removeById(tenantId, j.id));
    }

    Job[] search(TenantId tenantId, string query) {
        if (!existsByTenant(tenantId)) {
            return null;
        }
        auto q = query.toLower;
        return findByTenant(tenantId).filter!(j => j.name.toLower.canFind(q) || j.description.toLower.canFind(q))
            .array;
    }

    size_t countActiveByTenant(TenantId tenantId) {
        return findByTenant(tenantId).filter!(j => j.active).array.length;
    }

    size_t countInactiveByTenant(TenantId tenantId) {
        return findByTenant(tenantId).filter!(j => !j.active).array.length;
    }
}

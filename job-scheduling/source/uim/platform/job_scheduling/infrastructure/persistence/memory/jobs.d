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
class MemoryJobRepository : JobRepository {
    private Job[][TenantId] store; // keyed by tenantId

    bool existsByTenant(TenantId tenantId) {
        return (tenantId in store) ? true : false;
    }

    Job[] findByTenant(TenantId tenantId) {
        if (!existsByTenant(tenantId)) {
            return null;
        }
        return store[tenantId];
    }

    Job findById(TenantId tenantId, JobId jobId) {
        if (!existsByTenant(tenantId)) {
            return Job.init;
        }

        foreach (job; findByTenant(tenantId)) {
            if (job.id == jobId)
                return job;
        }
        return Job.init;
    }

    Job findByName(TenantId tenantId, string name) {
        if (!existsByTenant(tenantId)) {
            return Job.init;
        }

        foreach (job; findByTenant(tenantId)) {
            if (job.name == name)
                return job;
        }
        return Job.init;
    }

    Job[] findByStatus(TenantId tenantId, JobStatus status) {
        if (!existsByTenant(tenantId)) {
            return null;
        }
        return findByTenant(tenantId).filter!(j => j.status == status).array;
    }

    Job[] search(TenantId tenantId, string query) {
        if (!existsByTenant(tenantId)) {
            return null;
        }
        auto q = query.toLower;
        return findByTenant(tenantId).filter!(j => j.name.toLower.canFind(q) || j.description.toLower.canFind(q))
            .array;
    }

    void save(Job j) {
        store[j.tenantId] ~= j;
    }

    void update(Job j) {
        if (auto t = j.tenantId in store) {
            foreach (existing; *t) {
                if (existing.id == j.id) {
                    existing = j;
                    return;
                }
            }
        }
    }

    void remove(TenantId tenantId, JobId id) {
        if (auto t = tenantId in store) {
            *t = (*t).filter!(j => j.id != id).array;
        }
    }

    size_t countByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return (*t).length;
        return 0;
    }

    size_t countActiveByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return (*t).filter!(j => j.active).array.length;
        return 0;
    }

    size_t countInactiveByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return (*t).filter!(j => !j.active).array.length;
        return 0;
    }
}

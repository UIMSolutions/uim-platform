/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.job;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.job;
import uim.platform.job_scheduling.domain.ports.repositories.jobs;

import std.algorithm : filter, canFind;
import std.array : array;
import std.uni : toLower;

class MemoryJobRepository : JobRepository {
    private Job[][string] store; // keyed by tenantId

    Job findById(JobId tenantId, id tenantId) {
        if (auto t = tenantId in store) {
            foreach (ref j; *t) {
                if (j.id == id)
                    return j;
            }
        }
        return Job.init;
    }

    Job findByName(string name, TenantId tenantId) {
        if (auto t = tenantId in store) {
            foreach (ref j; *t) {
                if (j.name == name)
                    return j;
            }
        }
        return Job.init;
    }

    Job[] findByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return *t;
        return [];
    }

    Job[] findByStatus(JobStatus status, TenantId tenantId) {
        if (auto t = tenantId in store)
            return (*t).filter!(j => j.status == status).array;
        return [];
    }

    Job[] search(string query, TenantId tenantId) {
        if (auto t = tenantId in store) {
            auto q = query.toLower;
            return (*t).filter!(j => j.name.toLower.canFind(q) || j.description.toLower.canFind(q)).array;
        }
        return [];
    }

    void save(Job j) {
        store[j.tenantId] ~= j;
    }

    void update(Job j) {
        if (auto t = j.tenantId in store) {
            foreach (ref existing; *t) {
                if (existing.id == j.id) {
                    existing = j;
                    return;
                }
            }
        }
    }

    void remove(JobId tenantId, id tenantId) {
        if (auto t = tenantId in store) {
            *t = (*t).filter!(j => j.id != id).array;
        }
    }

    long countByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return cast(long)(*t).length;
        return 0;
    }

    long countActiveByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return cast(long)(*t).filter!(j => j.active).array.length;
        return 0;
    }

    long countInactiveByTenant(TenantId tenantId) {
        if (auto t = tenantId in store)
            return cast(long)(*t).filter!(j => !j.active).array.length;
        return 0;
    }
}

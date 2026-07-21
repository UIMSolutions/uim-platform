/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.repositories.builds;

import uim.platform.integration_delivery;
import std.algorithm : filter, sort;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryBuildRepository : TenantRepository!(Build, BuildId), BuildRepository {
    Build[] findByJob(TenantId tenantId, JobId jobId) {
        return findByTenant(tenantId).filter!(b => b.jobId == jobId).array;
    }

    Build[] findByStatus(TenantId tenantId, BuildStatus status) {
        return findByTenant(tenantId).filter!(b => b.status == status).array;
    }

    Build[] findByJobAndStatus(TenantId tenantId, JobId jobId, BuildStatus status) {
        return findByTenant(tenantId).filter!(b => b.jobId == jobId && b.status == status).array;
    }

    Build findLatestByJob(TenantId tenantId, JobId jobId) {
        auto results = findByJob(tenantId, jobId);
        if (results.length == 0) return Build.init;
        auto sorted = results.dup;
        sorted.sort!((a, b) => a.createdAt > b.createdAt);
        return sorted[0];
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.memory.stages;

import uim.platform.integration_delivery;
import std.algorithm : filter, sort;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryStageRepository : TentRepository!(Stage, StageId), StageRepository {
    Stage[] findByBuild(TenantId tenantId, BuildId buildId) {
        return findByTenant(tenantId).filter!(s => s.buildId == buildId).array;
    }

    Stage[] findByStatus(TenantId tenantId, StageStatus status) {
        return findByTenant(tenantId).filter!(s => s.status == status).array;
    }

    Stage[] findByBuildOrdered(TenantId tenantId, BuildId buildId) {
        auto results = findByBuild(tenantId, buildId);
        results.sort!((a, b) => a.order_ < b.order_);
        return results;
    }
}

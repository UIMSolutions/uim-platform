/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.memory.pipelines;

import uim.platform.integration_delivery;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryPipelineRepository : TenantRepository!(Pipeline, PipelineId), PipelineRepository {
    Pipeline[] findByStatus(TenantId tenantId, PipelineStatus status) {
        return findByTenant(tenantId).filter!(p => p.status == status).array;
    }

    Pipeline[] findByType(TenantId tenantId, PipelineType type) {
        return findByTenant(tenantId).filter!(p => p.pipelineType == type).array;
    }
}

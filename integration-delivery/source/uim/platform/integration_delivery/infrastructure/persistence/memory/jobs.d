/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.memory.jobs;

import uim.platform.integration_delivery;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryJobRepository : TenantRepository!(Job, JobId), JobRepository {
    Job[] findByPipeline(TenantId tenantId, PipelineId pipelineId) {
        return findByTenant(tenantId).filter!(j => j.pipelineId == pipelineId).array;
    }

    Job[] findByRepository(TenantId tenantId, CicdRepositoryId repositoryId) {
        return findByTenant(tenantId).filter!(j => j.repositoryId == repositoryId).array;
    }

    Job[] findByStatus(TenantId tenantId, JobStatus status) {
        return findByTenant(tenantId).filter!(j => j.status == status).array;
    }
}

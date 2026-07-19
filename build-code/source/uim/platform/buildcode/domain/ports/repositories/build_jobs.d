/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.build_jobs;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface BuildJobRepository : ITenantRepository!(BuildJob, BuildJobId) {
  BuildJob[]  findByPipeline(TenantId tenantId, string pipelineId);
  BuildJob[]  findByProject(TenantId tenantId, string projectId);
  BuildJob[]  findByStatus(TenantId tenantId, JobStatus status);
  BuildJob[]  findByBranch(TenantId tenantId, string branch);
}

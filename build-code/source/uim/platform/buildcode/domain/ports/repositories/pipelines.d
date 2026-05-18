/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.pipelines;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface PipelineRepository : ITenantRepository!(Pipeline, PipelineId) {
  Pipeline[]  findByProject(string tenantId, string projectId);
  Pipeline[]  findByStage(string tenantId, PipelineStage stage);
  Pipeline[]  findActive(string tenantId);
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.repositories.pipelines;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

interface PipelineRepository : ITentRepository!(Pipeline, PipelineId) {
    Pipeline[] findByStatus(TenantId tenantId, PipelineStatus status);
    Pipeline[] findByType(TenantId tenantId, PipelineType pipelineType);
}

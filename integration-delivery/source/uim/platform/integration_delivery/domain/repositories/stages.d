/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.repositories.stages;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

interface StageRepository : ITenantRepository!(Stage, StageId) {
    Stage[] findByBuild(TenantId tenantId, BuildId buildId);
    Stage[] findByStatus(TenantId tenantId, StageStatus status);
    Stage[] findByBuildOrdered(TenantId tenantId, BuildId buildId);
}

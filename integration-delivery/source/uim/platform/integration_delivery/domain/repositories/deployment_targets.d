/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.repositories.deployment_targets;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

interface DeploymentTargetRepository : ITentRepository!(DeploymentTarget, DeploymentTargetId) {
    DeploymentTarget[] findByStatus(TenantId tenantId, DeploymentTargetStatus status);
    DeploymentTarget[] findByType(TenantId tenantId, DeploymentTargetType targetType);
    bool nameExists(TenantId tenantId, string name);
}

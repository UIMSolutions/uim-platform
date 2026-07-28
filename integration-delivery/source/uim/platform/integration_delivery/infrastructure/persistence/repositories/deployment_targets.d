/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.repositories.deployment_targets;

import uim.platform.integration_delivery;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryDeploymentTargetRepository : TenantRepository!(DeploymentTarget, DeploymentTargetId), DeploymentTargetRepository {
    DeploymentTarget[] findByStatus(TenantId tenantId, DeploymentTargetStatus status) {
        return findByTenant(tenantId).filter!(d => d.status == status).array;
    }

    DeploymentTarget[] findByType(TenantId tenantId, DeploymentTargetType type) {
        return findByTenant(tenantId).filter!(d => d.targetType == type).array;
    }

    bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(d => d.name == name);
    }
}

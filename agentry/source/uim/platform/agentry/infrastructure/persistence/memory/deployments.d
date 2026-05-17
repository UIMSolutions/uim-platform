/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryDeploymentRepository
    : TenantRepository!(Deployment, DeploymentId), DeploymentRepository {

    Deployment[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByTenant(tenantId).filter!(d => d.mobileApplicationId == appId).array;
    }

    Deployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
        return findByTenant(tenantId).filter!(d => d.status == status).array;
    }

    Deployment[] findByAppVersion(TenantId tenantId, AppVersionId versionId) {
        return findByTenant(tenantId).filter!(d => d.appVersionId == versionId).array;
    }

    size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
        return findByStatus(tenantId, status).length;
    }
}

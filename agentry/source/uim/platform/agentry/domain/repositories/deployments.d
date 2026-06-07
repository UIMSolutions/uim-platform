/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.deployments;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

interface DeploymentRepository : ITenantRepository!(Deployment, DeploymentId) {
    Deployment[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    Deployment[] findByStatus(TenantId tenantId, DeploymentStatus status);
    Deployment[] findByAppVersion(TenantId tenantId, AppVersionId versionId);
    size_t countByStatus(TenantId tenantId, DeploymentStatus status);
}

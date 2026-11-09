/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.ports.repositories.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IDeploymentRepository : ITenantRepository!(Deployment, DeploymentId) {
    size_t countByStatus(TenantId tenantId, DeploymentStatus status);
    Deployment[] findByStatus(TenantId tenantId, DeploymentStatus status);
    void removeByStatus(TenantId tenantId, DeploymentStatus status);

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    Deployment[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId);

    size_t countByAppVersion(TenantId tenantId, AppVersionId versionId);
    Deployment[] findByAppVersion(TenantId tenantId, AppVersionId versionId);
    void removeByAppVersion(TenantId tenantId, AppVersionId versionId);
    
}

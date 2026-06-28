/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.repositories.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class DeploymentRepository
    : TenantRepository!(Deployment, DeploymentId), IDeploymentRepository {
    mixin TenantRepositoryTemplate!(DeploymentRepository, Deployment, DeploymentId);

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByMobileApplication(tenantId, appId).length;
    }
    Deployment[] filterByMobileApplication(Deployment[] deployments, MobileApplicationId appId) {
        return deployments.filter!(d => d.mobileApplicationId == appId).array;
    }
    Deployment[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return filterByMobileApplication(find(tenantId), appId);
    }
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Deployment[] filterByStatus(Deployment[] deployments, DeploymentStatus status) {
        return deployments.filter!(d => d.status == status).array;
    }

    Deployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
        return filterByStatus(find(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, DeploymentStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByAppVersion(TenantId tenantId, AppVersionId versionId) {
        return findByAppVersion(tenantId, versionId).length;
    }
    Deployment[] filterByAppVersion(Deployment[] deployments, AppVersionId versionId) {
        return deployments.filter!(d => d.appVersionId == versionId).array;
    }
    Deployment[] findByAppVersion(TenantId tenantId, AppVersionId versionId) {
        return filterByAppVersion(find(tenantId), versionId);
    }
    void removeByAppVersion(TenantId tenantId, AppVersionId versionId) {
        findByAppVersion(tenantId, versionId).each!(e => remove(e));
    }

}
///
unittest {
    assert(tenantRepositoryTest(new DeploymentRepository));
}
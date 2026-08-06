/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.manage.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IManageDeploymentsUseCase {

    Deployment getDeployment(TenantId tenantId, DeploymentId id);
    Deployment[] listDeployments(TenantId tenantId);
    Deployment[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    Deployment[] listByStatus(TenantId tenantId, DeploymentStatus status);

    CommandResult createDeployment(DeploymentDTO dto);
    CommandResult updateDeployment(DeploymentDTO dto);
    CommandResult deleteDeployment(TenantId tenantId, DeploymentId id);

}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.usecases.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Driving port: roll out app versions to devices, groups or a whole tenant.
interface IManageDeploymentsUseCase {
  Deployment[] listDeployments(TenantId tenantId);
  Deployment[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId);
  Deployment[] listByStatus(TenantId tenantId, DeploymentStatus status);
  Deployment getDeployment(TenantId tenantId, DeploymentId id);

  /// Plan a deployment. The app version must be published.
  UsecaseResult createDeployment(DeploymentDTO dto);
  UsecaseResult updateDeployment(DeploymentDTO dto);
  /// pending → deploying; resolves the targeted devices (devicesTotal).
  UsecaseResult startDeployment(TenantId tenantId, DeploymentId id, UserId by);
  /// deploying → deployed (or failed if no device succeeded).
  UsecaseResult completeDeployment(TenantId tenantId, DeploymentId id, long devicesSucceeded, long devicesFailed);
  UsecaseResult rollbackDeployment(TenantId tenantId, DeploymentId id, UserId by);
  UsecaseResult deleteDeployment(TenantId tenantId, DeploymentId id);
}

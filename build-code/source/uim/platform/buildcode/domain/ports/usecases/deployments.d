/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.deployments;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageDeploymentsUseCase {

  UsecaseResult create(TenantId tenantId, CreateDeploymentRequest req);
  Deployment getById(TenantId tenantId, DeploymentId id);
  Deployment[] list(TenantId tenantId);
  Deployment[] listByProject(TenantId tenantId, string projectId);
  Deployment[] listByEnvironment(TenantId tenantId, string envStr);
  UsecaseResult updateStatus(TenantId tenantId, string id, string statusStr, string url = "");
  
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.deployments;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface IManageDeploymentsUseCase { 

  CommandResult createDeployment(CreateDeploymentRequest r);
  CommandResult patchDeployment(PatchDeploymentRequest request);
  Deployment getDeployment(TenantId tenantId, ResourceGroupId rgId, DeploymentId deploymentId);
  Deployment[] listDeployments(TenantId tenantId, ResourceGroupId rgId);
  Deployment[] listDeployments(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  Deployment[] listDeployments(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status);
  CommandResult deleteDeployment(TenantId tenantId, ResourceGroupId rgId, DeploymentId deploymentId);

}

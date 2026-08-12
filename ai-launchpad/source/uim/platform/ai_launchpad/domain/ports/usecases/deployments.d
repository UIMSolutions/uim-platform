/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.deployments;
// import uim.platform.ai_launchpad.domain.ports.repositories.deployments;
// import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageDeploymentsUseCase { 

  CommandResult createDeployment(CreateDeploymentRequest r);

  Deployment getDeployment(TenantId tenantId, ConnectionId connectionId, DeploymentId id);

  Deployment[] listDeployments(TenantId tenantId, ConnectionId connectionId);

  Deployment[] listDeployments(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  CommandResult patchDeployment(PatchDeploymentRequest r);

  CommandResult[] bulkPatchDeployments(BulkPatchDeploymentRequest r);

  CommandResult deleteDeployment(TenantId tenantId, ConnectionId connectionId, DeploymentId id);

}

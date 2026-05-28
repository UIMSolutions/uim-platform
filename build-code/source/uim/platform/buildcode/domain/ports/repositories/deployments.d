/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.deployments;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface DeploymentRepository : ITenantRepository!(Deployment, DeploymentId) {
  Deployment[]  findByProject(TenantId tenantId, string projectId);
  Deployment[]  findByEnvironment(TenantId tenantId, DeploymentEnvironment env);
  Deployment[]  findByStatus(TenantId tenantId, DeploymentStatus status);
  Deployment[]  findByBuildJob(TenantId tenantId, string buildJobId);
}

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
  Deployment[]  findByProject(string tenantId, string projectId);
  Deployment[]  findByEnvironment(string tenantId, DeploymentEnvironment env);
  Deployment[]  findByStatus(string tenantId, DeploymentStatus status);
  Deployment[]  findByBuildJob(string tenantId, string buildJobId);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.build_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// How a project is built and deployed. Builds and deployments run
/// asynchronously (reconciler); the last runs are kept as history.
struct BuildConfiguration {
  mixin TenantEntity!BuildConfigurationId;

  ProjectId projectId;
  string projectName;
  DevSpaceId devSpaceId;
  string name; /// unique per project
  string description;
  BuildStatus status = BuildStatus.pending;
  string statusMessage;

  DeployTarget deployTarget = DeployTarget.cloudFoundry;
  string buildCommand = "mbt build";
  string deployCommand;
  string mtaDescriptor; /// e.g. "mta.yaml" (Cloud Foundry)
  string artifactPath; /// derived from target and project if empty
  string lastArtifact;
  BuildRun[] history;
  long lastBuildAt;
  long lastDeployAt;
}

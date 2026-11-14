/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Rules of build configurations: deploy target compatibility, artifacts, history.
module uim.platform.application_studio.domain.services.build_policy;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Number of build / deploy runs kept per configuration.
enum size_t maxBuildHistory = 20;

/// Check that a project of `projectType` can be deployed to `target` with the given settings.
void validateDeployTarget(ProjectType projectType, DeployTarget target, string mtaDescriptor) {
  final switch (target) {
  case DeployTarget.cloudFoundry:
    validate(mtaDescriptor.endsWith(".yaml") || mtaDescriptor.endsWith(".yml"),
      "Cloud Foundry deployments need an MTA descriptor (e.g. mta.yaml)");
    break;
  case DeployTarget.html5Repository, DeployTarget.abap:
    validate(projectType.isUiProject, "Only UI projects (SAP Fiori, SAPUI5, MDK) can be deployed to the "
        ~ enumText(target) ~ " repository (project type: " ~ enumText(projectType) ~ ")");
    break;
  case DeployTarget.kyma, DeployTarget.docker:
    validate(projectType != ProjectType.hanaNative, "HANA native projects cannot be deployed as containers");
    break;
  }
}

/// Default artifact location for a target ("" artifactPath in the configuration).
string defaultArtifactPath(DeployTarget target, string projectName) pure {
  final switch (target) {
  case DeployTarget.cloudFoundry:
    return "mta_archives/" ~ projectName ~ "_1.0.0.mtar";
  case DeployTarget.kyma:
    return "chart/" ~ projectName;
  case DeployTarget.abap, DeployTarget.html5Repository:
    return "dist/" ~ projectName ~ ".zip";
  case DeployTarget.docker:
    return projectName ~ ":latest";
  }
}

/// Default deploy command for a target.
string defaultDeployCommand(DeployTarget target, string artifactPath) pure {
  final switch (target) {
  case DeployTarget.cloudFoundry:
    return "cf deploy " ~ artifactPath;
  case DeployTarget.kyma:
    return "helm upgrade --install " ~ artifactPath;
  case DeployTarget.abap:
    return "npx fiori deploy";
  case DeployTarget.html5Repository:
    return "cf html5-push " ~ artifactPath;
  case DeployTarget.docker:
    return "docker push " ~ artifactPath;
  }
}

/// A build may start unless one is already in progress.
void ensureCanBuild(const BuildConfiguration bc) {
  ensureState(!bc.status.isBusy, "Build configuration '" ~ bc.name ~ "' is already " ~ enumText(bc.status));
}

/// A deployment needs a successful build (or a previous deployment of it).
void ensureCanDeploy(const BuildConfiguration bc) {
  ensureState(bc.status == BuildStatus.succeeded || bc.status == BuildStatus.deployed,
    "Build configuration '" ~ bc.name ~ "' needs a successful build before deploying (status: " ~ enumText(bc.status) ~ ")");
  ensureState(bc.lastArtifact.length > 0, "Build configuration '" ~ bc.name ~ "' has no artifact to deploy");
}

/// Append a run, keeping at most maxBuildHistory entries.
void recordRun(ref BuildConfiguration bc, BuildRun run) {
  bc.history ~= run;
  if (bc.history.length > maxBuildHistory)
    bc.history = bc.history[$ - maxBuildHistory .. $];
}

///
unittest {
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (StudioException)
      return true;
    return false;
  }

  validateDeployTarget(ProjectType.capNodeJs, DeployTarget.cloudFoundry, "mta.yaml");
  assert(failed(() => validateDeployTarget(ProjectType.capNodeJs, DeployTarget.cloudFoundry, "")));
  assert(failed(() => validateDeployTarget(ProjectType.capJava, DeployTarget.html5Repository, "")));
  validateDeployTarget(ProjectType.sapFiori, DeployTarget.abap, "");
  assert(defaultArtifactPath(DeployTarget.cloudFoundry, "travel") == "mta_archives/travel_1.0.0.mtar");
  assert(defaultDeployCommand(DeployTarget.docker, "travel:latest") == "docker push travel:latest");

  BuildConfiguration bc;
  bc.status = BuildStatus.building;
  assert(failed(() => ensureCanBuild(bc)));
  bc.status = BuildStatus.succeeded;
  assert(failed(() => ensureCanDeploy(bc))); // no artifact
  bc.lastArtifact = "x.mtar";
  ensureCanDeploy(bc);
  foreach (i; 0 .. maxBuildHistory + 5)
    recordRun(bc, BuildRun(i.to!string));
  assert(bc.history.length == maxBuildHistory && bc.history[$ - 1].runId == (maxBuildHistory + 4).to!string);
}

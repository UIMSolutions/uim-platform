/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations.builds;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Status of a build configuration (of its latest run).
///
///   pending | succeeded | failed | cancelled | deployed → building → succeeded | failed
///   succeeded | deployed → deploying → deployed | failed ;  building | deploying → cancelled
enum BuildStatus {
  pending,
  building,
  succeeded,
  failed,
  cancelled,
  deploying,
  deployed,
}

/// True while a build or deployment is in progress.
bool isBusy(BuildStatus s) pure nothrow {
  return s == BuildStatus.building || s == BuildStatus.deploying;
}

/// Phase of a build run.
enum BuildPhase {
  build,
  deploy,
}

/// Where a build is deployed to.
enum DeployTarget {
  cloudFoundry,
  kyma,
  abap,
  html5Repository,
  docker,
}

///
unittest {
  assert(BuildStatus.deploying.isBusy && !BuildStatus.deployed.isBusy);
  assert(parseEnum!DeployTarget("html5-repository", DeployTarget.cloudFoundry) == DeployTarget.html5Repository);
}

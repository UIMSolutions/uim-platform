/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.deployment;

import uim.platform.buildcode;
import std.conv : to;

mixin(ShowModule!());

@safe:

/// A deployment of a project artifact to a target environment
struct Deployment {
  mixin TenantEntity!(DeploymentId);

  ProjectId             projectId;
  BuildJobId            buildJobId;
  string                artifactVersion;
  DeploymentEnvironment targetEnvironment;
  DeploymentStatus      status;
  string                targetOrg;
  string                targetSpace;
  string                targetUrl;
  string                deployedBy;
  long                  deployedAtMs;
  string                errorMessage;

  Json toJson() const {
    auto j = entityToJson();
    j["projectId"]         = Json(projectId.value);
    j["buildJobId"]        = Json(buildJobId.value);
    j["artifactVersion"]   = Json(artifactVersion);
    j["targetEnvironment"] = Json(targetEnvironment.to!string);
    j["status"]            = Json(status.to!string);
    j["targetOrg"]         = Json(targetOrg);
    j["targetSpace"]       = Json(targetSpace);
    j["targetUrl"]         = Json(targetUrl);
    j["deployedBy"]        = Json(deployedBy);
    j["deployedAtMs"]      = Json(deployedAtMs);
    j["errorMessage"]      = Json(errorMessage);
    return j;
  }
}

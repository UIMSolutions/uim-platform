/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.build_job;

import uim.platform.buildcode;


mixin(ShowModule!());

@safe:

/// A single execution of a CI/CD pipeline
struct BuildJob {
  mixin TenantEntity!(BuildJobId);

  PipelineId   pipelineId;
  ProjectId    projectId;
  string       commitSha;
  string       branch;
  JobStatus    status;
  long         startedAtMs;   // epoch milliseconds
  long         finishedAtMs;
  string       triggeredBy;
  string       logUrl;
  string[]     artifactIds;
  string       errorMessage;

  Json toJson() const {
    auto j = entityToJson();
    j["pipelineId"]   = Json(pipelineId.value);
    j["projectId"]    = Json(projectId.value);
    j["commitSha"]    = Json(commitSha);
    j["branch"]       = Json(branch);
    j["status"]       = Json(status.to!string);
    j["startedAtMs"]  = Json(startedAtMs);
    j["finishedAtMs"] = Json(finishedAtMs);
    j["triggeredBy"]  = Json(triggeredBy);
    j["logUrl"]       = Json(logUrl);
    auto arr = Json.emptyArray;
    foreach (a; artifactIds) arr ~= Json(a);
    j["artifactIds"]  = arr;
    j["errorMessage"] = Json(errorMessage);
    return j;
  }
}

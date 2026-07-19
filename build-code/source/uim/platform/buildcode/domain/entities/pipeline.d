/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.pipeline;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

/// A CI/CD pipeline definition for a project
struct Pipeline {
  mixin TenantEntity!(PipelineId);

  ProjectId      projectId;
  string         name;
  string         description;
  PipelineStage  stage;
  string         repositoryUrl;
  string         branch;
  string         configFilePath;
  bool           isActive;
  string         triggerType;    // "manual" | "push" | "schedule"
  string         schedule;       // cron expression for scheduled trigger

  Json toJson() const {
    auto j = entityToJson();
    j["projectId"]      = Json(projectId.value);
    j["name"]           = Json(name);
    j["description"]    = Json(description);
    j["stage"]          = Json(stage.to!string);
    j["repositoryUrl"]  = Json(repositoryUrl);
    j["branch"]         = Json(branch);
    j["configFilePath"] = Json(configFilePath);
    j["isActive"]       = Json(isActive);
    j["triggerType"]    = Json(triggerType);
    j["schedule"]       = Json(schedule);
    return j;
  }
}

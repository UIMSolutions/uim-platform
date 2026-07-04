/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.ai_request;

import uim.platform.buildcode;


mixin(ShowModule!());

@safe:

/// A Joule AI code-generation request
struct AIRequest {
  mixin TenantEntity!(AIRequestId);

  ProjectId         projectId;
  string            requestedBy;
  AIGenerationType  generationType;
  string            prompt;
  string            generatedCode;
  string            targetFilePath;
  AIRequestStatus   status;
  string            modelUsed;
  string            errorMessage;
  long              completedAtMs;

  Json toJson() const {
    auto j = entityToJson();
    j["projectId"]      = Json(projectId.value);
    j["requestedBy"]    = Json(requestedBy);
    j["generationType"] = Json(generationType.to!string);
    j["prompt"]         = Json(prompt);
    j["generatedCode"]  = Json(generatedCode);
    j["targetFilePath"] = Json(targetFilePath);
    j["status"]         = Json(status.to!string);
    j["modelUsed"]      = Json(modelUsed);
    j["errorMessage"]   = Json(errorMessage);
    j["completedAtMs"]  = Json(completedAtMs);
    return j;
  }
}

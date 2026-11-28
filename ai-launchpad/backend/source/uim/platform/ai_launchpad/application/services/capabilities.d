/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// What the service supports (GET /capabilities, CLI "capabilities").
module uim.platform.ai_launchpad.application.services.capabilities;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

Json capabilitiesJson(string runtimeMode, const AilpPolicy policy) {
  Json texts(const string[] values) {
    auto a = Json.emptyArray;
    foreach (v; values)
      a ~= Json(v);
    return a;
  }

  auto j = Json.emptyObject;
  j["service"] = "uim-ai-launchpad";
  j["runtime"] = runtimeMode;
  j["areas"] = texts(["launchpad", "runtimes", "lifecycle", "registry", "genai", "administration"]);
  j["connectionTypes"] = texts(domainEnumValues!ConnectionType);
  j["executionStatuses"] = texts(domainEnumValues!ExecutionStatus);
  j["deploymentStatuses"] = texts(domainEnumValues!DeploymentStatus);
  j["promptStatuses"] = texts(domainEnumValues!PromptStatus);
  j["tileTargetTypes"] = texts(domainEnumValues!TileTargetType);
  j["logCategories"] = texts(domainEnumValues!LogCategory);
  j["kpis"] = texts(statisticNames);
  j["scopes"] = texts(knownScopes);
  j["builtInRoles"] = texts(builtInRoleDefinitions.map!(r => r.id).array);
  j["maxReplicas"] = maxReplicasLimit;
  auto p = Json.emptyObject;
  p["maxFailedLogins"] = policy.maxFailedLogins;
  p["lockSeconds"] = policy.lockSeconds;
  p["minPasswordLength"] = policy.minPasswordLength;
  p["logRetentionDays"] = policy.logRetentionDays;
  j["policy"] = p;
  return j;
}

///
unittest {
  auto j = capabilitiesJson("simulate", AilpPolicy.init);
  assert(j["runtime"].get!string == "simulate" && j["scopes"].length == 5 && j["kpis"].length > 10);
}

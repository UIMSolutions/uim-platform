/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// What the service supports (GET <api>/capabilities, CLI "capabilities").
module uim.platform.datasphere.application.services.capabilities;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

Json capabilitiesJson(string engineMode, const DspPolicy policy) {
  Json texts(const string[] values) {
    auto a = Json.emptyArray;
    foreach (v; values)
      a ~= Json(v);
    return a;
  }

  auto j = Json.emptyObject;
  j["apiVersion"] = "v1";
  j["processingEngine"] = engineMode;
  j["enforceQuota"] = policy.enforceQuota;
  j["runRetentionDays"] = policy.runRetentionDays;
  j["federatedRowEstimate"] = policy.federatedRowEstimate;
  j["columnTypes"] = texts(columnTypeWidths.keys.sort.array);
  j["columnSyntax"] = "NAME:TYPE[(length[,scale])] [key]";
  j["transformKinds"] = texts(transformKinds);
  j["viewSql"] = "a single SELECT / WITH … SELECT; sources are the objects after FROM and JOIN";
  j["scheduleIntervalMinutes"] = Json(["min": Json(minIntervalMinutes), "max": Json(maxIntervalMinutes)]);
  j["maxTaskRetries"] = maxTaskRetries;
  j["maxChainSteps"] = maxChainSteps;
  j["spaceStatuses"] = texts(domainEnumValues!SpaceStatus);
  j["spaceRoles"] = texts(domainEnumValues!SpaceRole);
  j["connectionTypes"] = texts(domainEnumValues!ConnectionType);
  j["connectionStatuses"] = texts(domainEnumValues!ConnectionStatus);
  j["replicationModes"] = texts(domainEnumValues!ReplicationMode);
  j["replicationStatuses"] = texts(domainEnumValues!ReplicationStatus);
  j["deploymentStatuses"] = texts(domainEnumValues!DeploymentStatus);
  j["viewSemantics"] = texts(domainEnumValues!ViewSemantic);
  j["loadModes"] = texts(domainEnumValues!LoadMode);
  j["taskTypes"] = texts(domainEnumValues!TaskType);
  j["frequencies"] = texts(domainEnumValues!ScheduleFrequency);
  j["failurePolicies"] = texts(domainEnumValues!FailurePolicy);
  j["runStatuses"] = texts(domainEnumValues!RunStatus);
  j["criteriaOperators"] = texts(domainEnumValues!CriteriaOperator);
  j["assetTypes"] = texts(domainEnumValues!AssetType);
  j["qualityStatuses"] = texts(domainEnumValues!QualityStatus);
  j["sensitivities"] = texts(domainEnumValues!Sensitivity);
  j["scopes"] = texts(knownScopes);
  return j;
}

///
unittest {
  auto j = capabilitiesJson("simulate", DspPolicy.init);
  assert(j["taskTypes"].length == 3 && j["processingEngine"].get!string == "simulate");
}

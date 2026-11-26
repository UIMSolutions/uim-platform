/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// What the service supports (GET <api>/capabilities): metric types,
/// operators, schedule kinds, limits and the instance controller.
module uim.platform.application_autoscaler.application.services.capabilities;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

Json capabilitiesJson(string instanceMode, const AasPolicy policy) {
  Json texts(const string[] values) {
    auto a = Json.emptyArray;
    foreach (v; values)
      a ~= Json(v);
    return a;
  }

  auto j = Json.emptyObject;
  j["apiVersion"] = "v1";
  j["instanceController"] = instanceMode;
  j["dynamicScaling"] = true;
  j["scheduleScaling"] = true;
  j["customMetrics"] = true;
  j["percentageAdjustments"] = true;
  j["maxInstances"] = maxInstancesLimit;
  j["breachDurationSeconds"] = Json(["min": Json(minBreachSeconds), "max": Json(maxBreachSeconds), "default": Json(120)]);
  j["coolDownSeconds"] = Json(["min": Json(minCoolDownSeconds), "max": Json(maxCoolDownSeconds), "default": Json(300)]);
  j["metricStaleSeconds"] = policy.metricStaleSeconds;
  j["metricRetentionHours"] = policy.metricRetentionHours;
  j["eventRetentionDays"] = policy.eventRetentionDays;
  j["metricTypes"] = texts(domainEnumValues!MetricType);
  j["operators"] = texts(domainEnumValues!ComparisonOperator);
  j["scheduleKinds"] = texts(domainEnumValues!ScheduleKind);
  j["policyStatuses"] = texts(domainEnumValues!PolicyStatus);
  j["bindingStatuses"] = texts(domainEnumValues!BindingStatus);
  j["metricAllowFrom"] = texts(domainEnumValues!MetricAllowFrom);
  j["triggers"] = texts(domainEnumValues!ScalingTrigger);
  j["directions"] = texts(domainEnumValues!ScalingDirection);
  j["statuses"] = texts(domainEnumValues!ScalingStatus);
  j["scopes"] = texts(knownScopes);
  return j;
}

///
unittest {
  auto j = capabilitiesJson("simulate", AasPolicy.init);
  assert(j["metricTypes"].length == 9 && j["instanceController"].get!string == "simulate");
}

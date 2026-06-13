/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.scaling_policy;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

/// The top-level scaling policy bound to an application.
/// Mirrors SAP Application Autoscaler policy structure.
struct ScalingPolicyEntity {
  mixin TenantEntity!ScalingPolicyId;

  AppBindingId appId; // CF application GUID or internal binding id
  int instanceMinCount; // >= 1
  int instanceMaxCount; // >= instanceMinCount
  PolicyStatus status;
  string timezone; // IANA tz, e.g. "Europe/Berlin"
  MetricAllowFrom customMetricAllowFrom;

  ScalingRuleEntity[] scalingRules;
  RecurringScheduleEntity[] recurringSchedules;
  SpecificDateScheduleEntity[] specificDateSchedules;

  Json toJson() const @safe {
    auto j = Json.emptyObject;
    .set("app_id", appId)
    .set("instance_min_count", instanceMinCount)
    .set("instance_max_count", instanceMaxCount)
    .set("status", status.to!string)
    .set("timezone", timezone)
    .set("custom_metric_allow_from", customMetricAllowFrom.to!string);

    auto rulesArr = Json.emptyArray;
    foreach (r; scalingRules)
      rulesArr ~= r.toJson();
    j["scaling_rules"] = rulesArr;

    auto recArr = Json.emptyArray;
    foreach (r; recurringSchedules)
      recArr ~= r.toJson();
    j["recurring_schedules"] = recArr;

    auto sdArr = Json.emptyArray;
    foreach (s; specificDateSchedules)
      sdArr ~= s.toJson();
    j["specific_date_schedules"] = sdArr;

    return j;
  }
}

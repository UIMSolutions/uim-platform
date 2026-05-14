/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.scaling_policy;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// The top-level scaling policy bound to an application.
/// Mirrors SAP Application Autoscaler policy structure.
struct ScalingPolicyEntity {
  PolicyId              id;
  AppBindingId          appId;          // CF application GUID or internal binding id
  TenantId              tenantId;
  int                   instanceMinCount;  // >= 1
  int                   instanceMaxCount;  // >= instanceMinCount
  PolicyStatus          status;
  string                timezone;          // IANA tz, e.g. "Europe/Berlin"
  MetricAllowFrom       customMetricAllowFrom;

  ScalingRuleEntity[]          scalingRules;
  RecurringScheduleEntity[]    recurringSchedules;
  SpecificDateScheduleEntity[] specificDateSchedules;

  long createdAt;
  long updatedAt;

  Json toJson() const @safe {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"]                   = Json(id);
    j["app_id"]               = Json(appId);
    j["tenant_id"]            = Json(tenantId);
    j["instance_min_count"]   = Json(instanceMinCount);
    j["instance_max_count"]   = Json(instanceMaxCount);
    j["status"]               = Json(status.to!string);
    j["timezone"]             = Json(timezone);
    j["custom_metric_allow_from"] = Json(metricAllowFromToString(customMetricAllowFrom));
    j["created_at"]           = Json(createdAt);
    j["updated_at"]           = Json(updatedAt);

    auto rulesArr = Json.emptyArray;
    foreach (r; scalingRules)       rulesArr ~= r.toJson();
    j["scaling_rules"] = rulesArr;

    auto recArr = Json.emptyArray;
    foreach (r; recurringSchedules) recArr ~= r.toJson();
    j["recurring_schedules"] = recArr;

    auto sdArr = Json.emptyArray;
    foreach (s; specificDateSchedules) sdArr ~= s.toJson();
    j["specific_date_schedules"] = sdArr;

    return j;
  }
}

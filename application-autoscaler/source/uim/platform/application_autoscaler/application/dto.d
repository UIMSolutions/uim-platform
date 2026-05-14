/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.dto;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Scaling Rule DTOs
// ---------------------------------------------------------------------------
struct ScalingRuleRequest {
  string metricType;         // e.g. "cpu", "memoryutil", "jobqueue"
  string customMetricName;
  int    threshold;
  string operator;           // "<", ">", "<=", ">="
  int    breachDurationSecs; // default 120
  int    coolDownSecs;       // default 300
  string adjustment;         // "+1", "-1", "+100%"
}

// ---------------------------------------------------------------------------
// Recurring Schedule DTOs
// ---------------------------------------------------------------------------
struct RecurringScheduleRequest {
  string startTime;
  string endTime;
  string startDate;
  string endDate;
  int[]  daysOfWeek;
  int[]  daysOfMonth;
  int    instanceMinCount;
  int    instanceMaxCount;
  int    initialMinInstanceCount;
}

// ---------------------------------------------------------------------------
// Specific Date Schedule DTOs
// ---------------------------------------------------------------------------
struct SpecificDateScheduleRequest {
  string startDateTime;
  string endDateTime;
  int    instanceMinCount;
  int    instanceMaxCount;
  int    initialMinInstanceCount;
}

// ---------------------------------------------------------------------------
// Scaling Policy DTOs
// ---------------------------------------------------------------------------
struct CreateScalingPolicyRequest {
  AppBindingId              appId;
  TenantId                  tenantId;
  int                       instanceMinCount;
  int                       instanceMaxCount;
  string                    timezone;
  string                    customMetricAllowFrom; // "same_app" | "bound_app"
  ScalingRuleRequest[]      scalingRules;
  RecurringScheduleRequest[] recurringSchedules;
  SpecificDateScheduleRequest[] specificDateSchedules;
}

struct UpdateScalingPolicyRequest {
  PolicyId                  id;
  int                       instanceMinCount;
  int                       instanceMaxCount;
  string                    timezone;
  string                    customMetricAllowFrom;
  ScalingRuleRequest[]      scalingRules;
  RecurringScheduleRequest[] recurringSchedules;
  SpecificDateScheduleRequest[] specificDateSchedules;
}

// ---------------------------------------------------------------------------
// App Binding DTOs
// ---------------------------------------------------------------------------
struct CreateAppBindingRequest {
  TenantId tenantId;
  string   appGuid;
  string   appName;
  string   serviceInstanceId;
}

struct UpdateAppBindingRequest {
  AppBindingId id;
  int          currentInstances;
}

// ---------------------------------------------------------------------------
// Custom Metric DTOs
// ---------------------------------------------------------------------------
struct SubmitCustomMetricRequest {
  AppBindingId appId;
  string       metricName;
  double       value;
  string       unit;
  long         timestamp;
}

// ---------------------------------------------------------------------------
// Scaling Trigger (internal use case request)
// ---------------------------------------------------------------------------
struct TriggerScalingRequest {
  AppBindingId appId;
  string       metricType;
  double       currentValue;
}

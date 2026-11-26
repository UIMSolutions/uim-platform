/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T).
module uim.platform.application_autoscaler.application.dtos.inputs;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct BindingInput {
  string name;
  string appGuid;
  string serviceInstanceId;
  string description;
  string policyId; /// "" = no policy
  int currentInstances = 1; /// on create only; later changes go through the scaling engine
}

struct PolicyInput {
  string name;
  string description;
  int instanceMinCount = 1;
  int instanceMaxCount = 5;
  string timezone = "UTC";
  string customMetricAllowFrom = "sameApp";
}

struct RuleInput {
  string policyId;
  string metricType = "cpu";
  string customMetricName;
  string operator = ">=";
  double threshold = 80;
  int breachDurationSeconds = 120;
  int coolDownSeconds = 300;
  string adjustment = "+1";
  bool enabled = true;
}

struct ScheduleInput {
  string policyId;
  string name;
  string kind = "recurring";
  string startTime;
  string endTime;
  string[] daysOfWeek;
  string[] daysOfMonth;
  string startDate;
  string endDate;
  string startDateTime;
  string endDateTime;
  int instanceMinCount = 1;
  int instanceMaxCount = 5;
  int initialMinInstanceCount;
  bool enabled = true;
}

/// Create a resource: an optional id ("" = generated) and the input.
struct CreateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput input;
}

/// Change a resource (PATCH semantics).
struct UpdateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput changes;
}

/// A create command with every member of the input set (tests, demo data).
CreateCommand!TInput createCommand(TInput)(TenantId t, UserId actor, string id, TInput input) {
  import std.traits : FieldNameTuple;

  CreateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.input.values = input;
  static foreach (name; FieldNameTuple!TInput)
    c.input.set(name);
  return c;
}

/// An update command changing the given members only.
UpdateCommand!TInput updateCommand(TInput)(TenantId t, UserId actor, string id, TInput values, string[] fields...) {
  UpdateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.changes.values = values;
  foreach (f; fields)
    c.changes.set(f);
  return c;
}

/// A metric value sent by the platform's collector or the application.
struct SubmitMetricRequest {
  TenantId tenantId;
  UserId actor;
  string bindingId; /// the binding, or
  string appGuid; /// the bound application
  string metricName;
  double value = 0;
  string unit;
  string measuredAt; /// ISO 8601; "" = now
  string source = "api";
  string senderAppGuid; /// application that sends a custom metric ("" = the bound application)
}

/// A constant load over a period (samples every stepSeconds up to now).
struct SimulateLoadRequest {
  TenantId tenantId;
  UserId actor;
  string bindingId;
  string metricName;
  double value = 0;
  int durationSeconds = 180;
  int stepSeconds = 30;
}

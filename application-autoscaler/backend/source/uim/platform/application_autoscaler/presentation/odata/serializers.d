/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Derived facts
/// (names of referenced resources, effective limits, counts) are passed in
/// by the engine, which computes them once per request.
module uim.platform.application_autoscaler.presentation.odata.serializers;

import std.traits : FieldNameTuple;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// ISO 8601 date-time (seconds, UTC) or null for 0.
Json isoTime(long stdTime) {
  auto text = isoTimeText(stdTime);
  return text.length > 0 ? Json(text) : Json(null);
}

Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Empty text → null (optional values and references).
Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

/// Round to 4 digits (stable JSON).
double rounded(double v) pure {
  import std.math : round;

  return round(v * 10_000) / 10_000;
}

private Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

/// Facts about a binding computed by the engine.
struct BindingFacts {
  string policyName;
  string policyStatus;
  int minInstances;
  int maxInstances;
  string limitSource;
  long samples;
  long lastMetricAt;
  long events;
}

Json bindingRow(const AppBinding b, const BindingFacts f) {
  auto j = auditRow(b);
  j["name"] = b.name;
  j["appGuid"] = b.appGuid;
  j["serviceInstanceId"] = b.serviceInstanceId;
  j["description"] = b.description;
  j["policyId"] = textOrNull(b.policyId.value);
  j["policyName"] = f.policyName;
  j["policyStatus"] = f.policyStatus;
  j["status"] = cast(string) b.status;
  j["autoscaled"] = b.isAutoscaled && f.policyStatus == cast(string) PolicyStatus.active;
  j["currentInstances"] = b.currentInstances;
  j["minInstances"] = f.minInstances;
  j["maxInstances"] = f.maxInstances;
  j["limitSource"] = f.limitSource;
  j["utilizationPercent"] = f.maxInstances > 0 ? cast(int)(100.0 * b.currentInstances / f.maxInstances + 0.5) : 0;
  j["lastScaledAt"] = isoTime(b.lastScaledAt);
  j["lastEvaluatedAt"] = isoTime(b.lastEvaluatedAt);
  j["lastDecision"] = b.lastDecision;
  j["sampleCount"] = f.samples;
  j["lastMetricAt"] = isoTime(f.lastMetricAt);
  j["eventCount"] = f.events;
  return j;
}

struct PolicyFacts {
  long rules;
  long schedules;
  long bindings;
  string activeSchedule;
}

Json policyRow(const ScalingPolicy p, const PolicyFacts f) {
  auto j = auditRow(p);
  j["name"] = p.name;
  j["description"] = p.description;
  j["instanceMinCount"] = p.instanceMinCount;
  j["instanceMaxCount"] = p.instanceMaxCount;
  j["timezone"] = p.timezone;
  j["customMetricAllowFrom"] = cast(string) p.customMetricAllowFrom;
  j["status"] = cast(string) p.status;
  j["ruleCount"] = f.rules;
  j["scheduleCount"] = f.schedules;
  j["bindingCount"] = f.bindings;
  j["activeScheduleName"] = f.activeSchedule;
  return j;
}

Json ruleRow(const ScalingRule r, string policyName) {
  auto j = auditRow(r);
  j["policyId"] = r.policyId.value;
  j["policyName"] = policyName;
  j["metricType"] = cast(string) r.metricType;
  j["customMetricName"] = r.customMetricName;
  j["metricName"] = r.metricName;
  j["operator"] = cast(string) r.operator;
  j["threshold"] = rounded(r.threshold);
  j["unit"] = metricUnit(r.metricType);
  j["breachDurationSeconds"] = r.breachDurationSeconds;
  j["coolDownSeconds"] = r.coolDownSeconds;
  j["adjustment"] = r.adjustment;
  string direction;
  try
    direction = cast(string) r.direction;
  catch (AutoscalerException)
    direction = "";
  j["direction"] = direction;
  j["enabled"] = r.enabled;
  j["summary"] = r.summary;
  return j;
}

Json scheduleRow(const ScalingSchedule s, string policyName, string timezone, bool active) {
  auto j = auditRow(s);
  j["policyId"] = s.policyId.value;
  j["policyName"] = policyName;
  j["name"] = s.name;
  j["kind"] = cast(string) s.kind;
  j["startTime"] = s.startTime;
  j["endTime"] = s.endTime;
  j["daysOfWeek"] = texts(s.daysOfWeek);
  j["daysOfMonth"] = texts(s.daysOfMonth);
  j["daysText"] = daysText(s);
  j["startDate"] = s.startDate;
  j["endDate"] = s.endDate;
  j["startDateTime"] = s.startDateTime;
  j["endDateTime"] = s.endDateTime;
  j["instanceMinCount"] = s.instanceMinCount;
  j["instanceMaxCount"] = s.instanceMaxCount;
  j["initialMinInstanceCount"] = s.initialMinInstanceCount;
  j["enabled"] = s.enabled;
  j["active"] = active;
  j["timezone"] = timezone;
  j["summary"] = s.summary;
  return j;
}

/// ["1","2","3","4","5"] → "Mon–Fri"; ["1","3"] → "Mon, Wed"; month days "1, 15".
string daysText(const ScalingSchedule s) {
  enum string[] names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  if (s.kind == ScheduleKind.specificDate)
    return "";
  if (s.daysOfMonth.length)
    return "Day " ~ s.daysOfMonth.join(", ");
  int[] d;
  foreach (x; s.daysOfWeek) {
    try
      d ~= x.to!int;
    catch (Exception) {
    }
  }
  if (d.length == 0)
    return "";
  bool consecutive = d.length > 2;
  foreach (i; 1 .. d.length)
    if (d[i] != d[i - 1] + 1)
      consecutive = false;
  if (consecutive && d[0] >= 1 && d[$ - 1] <= 7)
    return names[d[0] - 1] ~ "–" ~ names[d[$ - 1] - 1];
  return d.filter!(x => x >= 1 && x <= 7).map!(x => names[x - 1]).join(", ");
}

Json sampleRow(const MetricSample m, string bindingName) {
  auto j = auditRow(m);
  j["bindingId"] = m.bindingId.value;
  j["bindingName"] = bindingName;
  j["metricName"] = m.metricName;
  j["custom"] = m.isCustom;
  j["value"] = rounded(m.value);
  j["unit"] = m.unit;
  j["measuredAt"] = isoTime(m.measuredAt);
  j["source"] = m.source;
  return j;
}

Json eventRow(const ScalingEvent e, string bindingName, string policyName) {
  auto j = auditRow(e);
  j["bindingId"] = e.bindingId.value;
  j["bindingName"] = bindingName;
  j["policyId"] = textOrNull(e.policyId.value);
  j["policyName"] = policyName;
  j["ruleId"] = textOrNull(e.ruleId.value);
  j["scheduleId"] = textOrNull(e.scheduleId.value);
  j["trigger"] = cast(string) e.trigger;
  j["direction"] = cast(string) e.direction;
  j["status"] = cast(string) e.status;
  j["oldInstances"] = e.oldInstances;
  j["newInstances"] = e.newInstances;
  j["delta"] = e.delta;
  j["metricName"] = e.metricName;
  j["metricValue"] = rounded(e.metricValue);
  j["threshold"] = rounded(e.threshold);
  j["reason"] = e.reason;
  j["message"] = e.message;
  return j;
}

Json userRow(const UserAccount u, long now) {
  auto j = auditRow(u);
  j["displayName"] = u.displayName;
  j["password"] = Json(null);
  j["scopes"] = texts(u.scopes);
  j["scopesText"] = u.scopes.join(", ");
  j["locked"] = u.locked;
  j["temporarilyLocked"] = !u.locked && u.isLockedAt(now);
  j["failedLogins"] = u.failedLogins;
  j["lastLoginAt"] = isoTime(u.lastLoginAt);
  return j;
}

Json statisticsRow(const AasStatistics s) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!AasStatistics) {
    static if (name == "tenantId")
      j[name] = s.tenantId.value;
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

Json evaluationRow(const EvaluationResult r) {
  auto j = Json.emptyObject;
  j["bindingId"] = r.bindingId.value;
  j["bindingName"] = r.bindingName;
  j["trigger"] = cast(string) r.trigger;
  j["direction"] = cast(string) r.direction;
  j["status"] = cast(string) r.status;
  j["oldInstances"] = r.oldInstances;
  j["newInstances"] = r.newInstances;
  j["minInstances"] = r.minInstances;
  j["maxInstances"] = r.maxInstances;
  j["limitSource"] = r.limitSource;
  j["reason"] = r.reason;
  j["message"] = r.message;
  j["eventId"] = textOrNull(r.eventId.value);
  return j;
}

/// A decision that is only shown (status "preview").
Json previewRow(const AppBinding b, const ScalingDecision d) {
  EvaluationResult r;
  r.bindingId = b.id;
  r.bindingName = b.name;
  r.trigger = d.trigger;
  r.direction = d.changes ? (d.target > d.current ? ScalingDirection.scaleOut : ScalingDirection.scaleIn) : ScalingDirection.none;
  r.oldInstances = d.current;
  r.newInstances = d.target;
  r.minInstances = d.limits.min;
  r.maxInstances = d.limits.max;
  r.limitSource = d.limits.source;
  r.reason = d.reason;
  auto j = evaluationRow(r);
  j["status"] = "preview";
  return j;
}

Json summaryRow(const EvaluationSummary s) {
  auto j = Json.emptyObject;
  j["bindings"] = s.bindings;
  j["evaluated"] = s.evaluated;
  j["scaledOut"] = s.scaledOut;
  j["scaledIn"] = s.scaledIn;
  j["unchanged"] = s.unchanged;
  j["failed"] = s.failed;
  j["skipped"] = s.skipped;
  j["messages"] = s.messages.join("\n");
  return j;
}

Json simulationRow(string bindingId, string metric, double value, size_t samples) {
  auto j = Json.emptyObject;
  j["bindingId"] = bindingId;
  j["metricName"] = metric;
  j["value"] = rounded(value);
  j["samples"] = samples;
  return j;
}

Json purgeRow(const PurgeResult r) {
  return Json(["samples": Json(r.samples), "events": Json(r.events)]);
}

Json seedRow(const SeedResult r) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!SeedResult)
    j[name] = __traits(getMember, r, name);
  return j;
}

///
unittest {
  ScalingSchedule s;
  s.daysOfWeek = ["1", "2", "3", "4", "5"];
  assert(daysText(s) == "Mon–Fri");
  s.daysOfWeek = ["1", "3"];
  assert(daysText(s) == "Mon, Wed");
  s.daysOfWeek = null;
  s.daysOfMonth = ["1", "15"];
  assert(daysText(s) == "Day 1, 15");
  AppBinding b;
  b.currentInstances = 3;
  BindingFacts f;
  f.maxInstances = 6;
  assert(bindingRow(b, f)["utilizationPercent"].get!long == 50);
  assert(rounded(0.123456) == 0.1235);
}

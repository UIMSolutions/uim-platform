/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (reads), Operate (metrics, evaluations, manual scaling,
/// suspend / resume), Manage (bindings, policies, rules, schedules), Admin
/// (Users). Timestamps are Edm.DateTimeOffset; schedule times are local
/// times of the policy's time zone (strings).
module uim.platform.application_autoscaler.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.autoscaler";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

ODataServiceModel autoscalerModel() {
  auto m = new ODataServiceModel(odataNamespace, "AutoscalerService", "Application Autoscaler");

  // ── bindings ────────────────────────────────────────────────────────────
  audited(m.entitySet("Bindings", "Binding")
      .property("id", Edm.string_, "Binding", false)
      .property("name", Edm.string_, "Application", false)
      .property("appGuid", Edm.string_, "Application GUID", false)
      .property("serviceInstanceId", Edm.string_, "Service Instance")
      .property("description", Edm.string_, "Description")
      .property("policyId", Edm.string_, "Policy")
      .property("policyName", Edm.string_, "Policy Name")
      .property("policyStatus", Edm.string_, "Policy Status")
      .property("status", Edm.string_, "Autoscaling")
      .property("autoscaled", Edm.boolean, "Autoscaled")
      .property("currentInstances", Edm.int32, "Instances")
      .property("minInstances", Edm.int32, "Minimum")
      .property("maxInstances", Edm.int32, "Maximum")
      .property("limitSource", Edm.string_, "Limits From")
      .property("utilizationPercent", Edm.int32, "Of Maximum (%)")
      .property("lastScaledAt", Edm.dateTimeOffset, "Last Scaled")
      .property("lastEvaluatedAt", Edm.dateTimeOffset, "Last Evaluated")
      .property("lastDecision", Edm.string_, "Last Decision")
      .property("sampleCount", Edm.int32, "Samples")
      .property("lastMetricAt", Edm.dateTimeOffset, "Last Metric")
      .property("eventCount", Edm.int32, "Scaling Events")
      .computed("policyName", "policyStatus", "status", "autoscaled", "minInstances", "maxInstances", "limitSource",
        "utilizationPercent", "lastScaledAt", "lastEvaluatedAt", "lastDecision", "sampleCount", "lastMetricAt", "eventCount")
      .immutableProps("appGuid", "currentInstances"))
    .writable()
    .titled("Binding", "Bindings", "name", "policyName")
    .columns("name", "policyName", "status", "currentInstances", "minInstances", "maxInstances", "lastScaledAt")
    .filters("status", "policyId", "autoscaled", "serviceInstanceId")
    .scopes(readScope, manageScope);

  // ── policies, rules, schedules ──────────────────────────────────────────
  audited(m.entitySet("Policies", "Policy")
      .property("id", Edm.string_, "Policy", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("instanceMinCount", Edm.int32, "Minimum Instances")
      .property("instanceMaxCount", Edm.int32, "Maximum Instances")
      .property("timezone", Edm.string_, "Time Zone")
      .property("customMetricAllowFrom", Edm.string_, "Custom Metrics From")
      .property("status", Edm.string_, "Status")
      .property("ruleCount", Edm.int32, "Rules")
      .property("scheduleCount", Edm.int32, "Schedules")
      .property("bindingCount", Edm.int32, "Bindings")
      .property("activeScheduleName", Edm.string_, "Active Schedule")
      .computed("status", "ruleCount", "scheduleCount", "bindingCount", "activeScheduleName"))
    .writable()
    .titled("Policy", "Policies", "name", "description")
    .columns("name", "status", "instanceMinCount", "instanceMaxCount", "ruleCount", "scheduleCount", "bindingCount")
    .filters("status", "timezone")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Rules", "Rule")
      .property("id", Edm.string_, "Rule", false)
      .property("policyId", Edm.string_, "Policy", false)
      .property("policyName", Edm.string_, "Policy Name")
      .property("metricType", Edm.string_, "Metric Type")
      .property("customMetricName", Edm.string_, "Custom Metric")
      .property("metricName", Edm.string_, "Metric")
      .property("operator", Edm.string_, "Operator")
      .property("threshold", Edm.double_, "Threshold")
      .property("unit", Edm.string_, "Unit")
      .property("breachDurationSeconds", Edm.int32, "Breach Duration (s)")
      .property("coolDownSeconds", Edm.int32, "Cool-Down (s)")
      .property("adjustment", Edm.string_, "Adjustment")
      .property("direction", Edm.string_, "Direction")
      .property("enabled", Edm.boolean, "Enabled")
      .property("summary", Edm.string_, "Rule")
      .computed("policyName", "metricName", "unit", "direction", "summary")
      .immutableProps("policyId"))
    .writable()
    .titled("Scaling Rule", "Scaling Rules", "summary", "policyName")
    .columns("metricName", "operator", "threshold", "breachDurationSeconds", "coolDownSeconds", "adjustment", "enabled")
    .filters("policyId", "metricType", "direction", "enabled")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Schedules", "Schedule")
      .property("id", Edm.string_, "Schedule", false)
      .property("policyId", Edm.string_, "Policy", false)
      .property("policyName", Edm.string_, "Policy Name")
      .property("name", Edm.string_, "Name")
      .property("kind", Edm.string_, "Kind")
      .property("startTime", Edm.string_, "Start Time")
      .property("endTime", Edm.string_, "End Time")
      .collection("daysOfWeek", Edm.string_, "Days of the Week")
      .collection("daysOfMonth", Edm.string_, "Days of the Month")
      .property("daysText", Edm.string_, "Days")
      .property("startDate", Edm.string_, "Valid From")
      .property("endDate", Edm.string_, "Valid To")
      .property("startDateTime", Edm.string_, "Start")
      .property("endDateTime", Edm.string_, "End")
      .property("instanceMinCount", Edm.int32, "Minimum Instances")
      .property("instanceMaxCount", Edm.int32, "Maximum Instances")
      .property("initialMinInstanceCount", Edm.int32, "Initial Minimum")
      .property("enabled", Edm.boolean, "Enabled")
      .property("active", Edm.boolean, "Active Now")
      .property("timezone", Edm.string_, "Time Zone")
      .property("summary", Edm.string_, "Schedule")
      .computed("policyName", "daysText", "active", "timezone", "summary")
      .immutableProps("policyId", "kind"))
    .writable()
    .titled("Schedule", "Schedules", "name", "summary")
    .columns("name", "kind", "summary", "instanceMinCount", "instanceMaxCount", "enabled", "active")
    .filters("policyId", "kind", "enabled", "active")
    .scopes(readScope, manageScope);

  // ── metrics and history ─────────────────────────────────────────────────
  audited(m.entitySet("MetricSamples", "MetricSample")
      .property("id", Edm.string_, "Sample", false)
      .property("bindingId", Edm.string_, "Binding", false)
      .property("bindingName", Edm.string_, "Application")
      .property("metricName", Edm.string_, "Metric", false)
      .property("custom", Edm.boolean, "Custom Metric")
      .property("value", Edm.double_, "Value", false)
      .property("unit", Edm.string_, "Unit")
      .property("measuredAt", Edm.dateTimeOffset, "Measured At")
      .property("source", Edm.string_, "Source")
      .computed("bindingName", "custom"))
    .writable(true, false, true)
    .titled("Metric Sample", "Metric Samples", "metricName", "bindingName")
    .columns("bindingName", "metricName", "value", "unit", "measuredAt", "source")
    .filters("bindingId", "metricName", "source", "custom")
    .scopes(readScope, operateScope);

  audited(m.entitySet("ScalingEvents", "ScalingEvent")
      .property("id", Edm.string_, "Event", false)
      .property("bindingId", Edm.string_, "Binding")
      .property("bindingName", Edm.string_, "Application")
      .property("policyId", Edm.string_, "Policy")
      .property("policyName", Edm.string_, "Policy Name")
      .property("ruleId", Edm.string_, "Rule")
      .property("scheduleId", Edm.string_, "Schedule")
      .property("trigger", Edm.string_, "Trigger")
      .property("direction", Edm.string_, "Direction")
      .property("status", Edm.string_, "Status")
      .property("oldInstances", Edm.int32, "From")
      .property("newInstances", Edm.int32, "To")
      .property("delta", Edm.int32, "Change")
      .property("metricName", Edm.string_, "Metric")
      .property("metricValue", Edm.double_, "Value")
      .property("threshold", Edm.double_, "Threshold")
      .property("reason", Edm.string_, "Reason")
      .property("message", Edm.string_, "Message"))
    .writable(false, false, false)
    .titled("Scaling Event", "Scaling History", "reason", "bindingName")
    .columns("createdAt", "bindingName", "trigger", "direction", "oldInstances", "newInstances", "status")
    .filters("bindingId", "policyId", "trigger", "direction", "status")
    .scopes(readScope, manageScope);

  // ── built-in login ──────────────────────────────────────────────────────
  audited(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("password", Edm.string_, "Password")
      .collection("scopes", Edm.string_, "Scopes")
      .property("scopesText", Edm.string_, "Scopes")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopesText", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "scopesText", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  // ── statistics ──────────────────────────────────────────────────────────
  auto stats = m.singletonSet("Statistics", "Statistic").keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false);
  foreach (name; statisticNames)
    stats.property(name, Edm.int32, statisticLabel(name));
  stats.titled("Statistics", "Statistics", "tenantId").scopes(readScope, manageScope);

  // ── result types ────────────────────────────────────────────────────────
  m.complexType("EvaluationResult")
    .property("bindingId", Edm.string_, "Binding")
    .property("bindingName", Edm.string_, "Application")
    .property("trigger", Edm.string_, "Trigger")
    .property("direction", Edm.string_, "Direction")
    .property("status", Edm.string_, "Status")
    .property("oldInstances", Edm.int32, "From")
    .property("newInstances", Edm.int32, "To")
    .property("minInstances", Edm.int32, "Minimum")
    .property("maxInstances", Edm.int32, "Maximum")
    .property("limitSource", Edm.string_, "Limits From")
    .property("reason", Edm.string_, "Reason")
    .property("message", Edm.string_, "Message")
    .property("eventId", Edm.string_, "Event");
  m.complexType("EvaluationSummary")
    .property("bindings", Edm.int32, "Bindings")
    .property("evaluated", Edm.int32, "Evaluated")
    .property("scaledOut", Edm.int32, "Scaled Out")
    .property("scaledIn", Edm.int32, "Scaled In")
    .property("unchanged", Edm.int32, "Unchanged")
    .property("failed", Edm.int32, "Failed")
    .property("skipped", Edm.int32, "Skipped")
    .property("messages", Edm.string_, "Messages");
  m.complexType("SimulationResult")
    .property("bindingId", Edm.string_, "Binding")
    .property("metricName", Edm.string_, "Metric")
    .property("value", Edm.double_, "Value")
    .property("samples", Edm.int32, "Samples");
  m.complexType("PurgeResult")
    .property("samples", Edm.int32, "Samples")
    .property("events", Edm.int32, "Events");
  m.complexType("SeedResult")
    .property("bindings", Edm.int32)
    .property("policies", Edm.int32)
    .property("rules", Edm.int32)
    .property("schedules", Edm.int32)
    .property("samples", Edm.int32);

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("EvaluateBinding", "EvaluationResult").parameter("id", Edm.string_, false).labelled("Evaluate Now")
    .requires(operateScope);
  m.action("PreviewScaling", "EvaluationResult").parameter("id", Edm.string_, false).labelled("Preview Decision")
    .requires(readScope);
  m.action("EvaluateAll", "EvaluationSummary").labelled("Evaluate All Bindings").requires(operateScope);
  m.action("ScaleBinding", "EvaluationResult").parameter("id", Edm.string_, false).parameter("instances", Edm.int32, false)
    .parameter("reason", Edm.string_).labelled("Scale Manually").requires(operateScope);
  m.action("SuspendBinding", "Binding").parameter("id", Edm.string_, false).labelled("Suspend Autoscaling").requires(operateScope);
  m.action("ResumeBinding", "Binding").parameter("id", Edm.string_, false).labelled("Resume Autoscaling").requires(operateScope);
  m.action("AttachPolicy", "Binding").parameter("id", Edm.string_, false).parameter("policyId", Edm.string_, false)
    .labelled("Attach Policy").requires(manageScope);
  m.action("DetachPolicy", "Binding").parameter("id", Edm.string_, false).labelled("Detach Policy").requires(manageScope);
  m.action("ActivatePolicy", "Policy").parameter("id", Edm.string_, false).labelled("Activate").requires(manageScope);
  m.action("DeactivatePolicy", "Policy").parameter("id", Edm.string_, false).labelled("Deactivate").requires(manageScope);
  m.action("CopyPolicy", "Policy").parameter("id", Edm.string_, false).parameter("newId", Edm.string_)
    .labelled("Copy").requires(manageScope);
  m.action("SimulateLoad", "SimulationResult").parameter("bindingId", Edm.string_, false)
    .parameter("metricName", Edm.string_, false).parameter("value", Edm.double_, false)
    .parameter("durationSeconds", Edm.int32).parameter("stepSeconds", Edm.int32)
    .labelled("Simulate Load").requires(operateScope);
  m.action("PurgeMetrics", "PurgeResult").labelled("Purge Old Samples and Events").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);
  return m;
}

/// Numeric members of the Statistics singleton (all of AasStatistics but the tenant).
enum string[] statisticNames = [
    "bindings", "autoscaledBindings", "suspendedBindings", "instances", "policies", "activePolicies", "rules",
    "schedules", "activeSchedules", "metricSamples", "samplesLast24h", "scalingEvents", "scaleOutsLast24h",
    "scaleInsLast24h", "failedLast24h", "users"
  ];

/// "scaleOutsLast24h" → "Scale Outs (24 h)"
string statisticLabel(string name) {
  import std.uni : isUpper, toUpper;

  string label;
  foreach (i, dchar c; name) {
    if (i == 0)
      label ~= toUpper(c);
    else {
      if (isUpper(c))
        label ~= ' ';
      label ~= c;
    }
  }
  return label.replace(" Last24h", " (24 h)").replace("Last24h", " (24 h)");
}

///
unittest {
  import std.traits : FieldNameTuple;

  auto m = autoscalerModel();
  m.validate();
  assert(m.has("Bindings") && m.find("Statistics").singleton && m.find("Rules").key == "id");
  assert(!m.find("ScalingEvents").insertable && !m.find("MetricSamples").updatable);
  assert(m.find("Bindings").propertyOf("appGuid").immutable_ && m.find("Bindings").propertyOf("status").computed);
  assert(m.findAction("EvaluateAll").returnEdmType == "uim.autoscaler.EvaluationSummary");
  assert(statisticLabel("scaleOutsLast24h") == "Scale Outs (24 h)", statisticLabel("scaleOutsLast24h"));
  // the statistics model and the port agree
  string[] fields;
  static foreach (name; FieldNameTuple!AasStatistics)
    static if (name != "tenantId")
      fields ~= name;
  assert(fields == statisticNames, fields.to!string);
}

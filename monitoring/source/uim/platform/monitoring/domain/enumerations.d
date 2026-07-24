/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.enumerations;

import uim.platform.monitoring;

mixin(ShowModule!());

@safe:

/// Type of monitored resource.
enum ResourceType {
  javaApplication,
  html5Application,
  hanaXsApplication,
  databaseSystem,
  nodeApplication,
  customApplication,
  service,
}
ResourceType toResourceType(string value) {
  mixin(EnumSwitch("ResourceType", "customApplication"));
}
ResourceType[] toResourceType(string[] values) {
  return values.map!(toResourceType).array;
}
string toString(ResourceType value) {
  return value.to!string;
}
string[] toStrings(ResourceType[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ResourceType"));

  assert("javaApplication".toResourceType == ResourceType.javaApplication);
  assert("html5Application".toResourceType == ResourceType.html5Application);
  assert("hanaXsApplication".toResourceType == ResourceType.hanaXsApplication);
  assert("databaseSystem".toResourceType == ResourceType.databaseSystem);
  assert("nodeApplication".toResourceType == ResourceType.nodeApplication);
  assert("customApplication".toResourceType == ResourceType.customApplication);
  assert("service".toResourceType == ResourceType.service);

  assert("unknown".toResourceType == ResourceType.customApplication);
  assert("".toResourceType == ResourceType.customApplication);

  assert(ResourceType.javaApplication.toString == "javaApplication");
  assert(ResourceType.html5Application.toString == "html5Application");
  assert(ResourceType.hanaXsApplication.toString == "hanaXsApplication");
  assert(ResourceType.databaseSystem.toString == "databaseSystem");
  assert(ResourceType.nodeApplication.toString == "nodeApplication");
  assert(ResourceType.customApplication.toString == "customApplication");
  assert(ResourceType.service.toString == "service");

  assert(toStrings([ResourceType.javaApplication, ResourceType.service]) == ["javaApplication", "service"]);
  assert(toResourceType(["javaApplication", "service"]) == [ResourceType.javaApplication, ResourceType.service]);
}

/// Current state of a monitored resource.
enum ResourceState {
  /// Default state when the resource state is unknown or not reported.
  unknown,
  /// The resource is running and healthy.
  started,
  /// The resource is stopped or not running.
  stopped,
  /// The resource is in an error state.
  error,
}
ResourceState toResourceState(string value) {
  mixin(EnumSwitch("ResourceState", "unknown"));
}
ResourceState[] toResourceState(string[] values) {
  return values.map!(toResourceState).array;
}
string toString(ResourceState state) {
  return state.to!string;
}
string[] toStrings(ResourceState[] states) {
  return states.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ResourceState"));

  assert("unknown".toResourceState == ResourceState.unknown);
  assert("started".toResourceState == ResourceState.started);
  assert("stopped".toResourceState == ResourceState.stopped);
  assert("error".toResourceState == ResourceState.error); 

  assert("some".toResourceState == ResourceState.unknown);
  assert("".toResourceState == ResourceState.unknown);

  assert(ResourceState.unknown.toString == "unknown");
  assert(ResourceState.started.toString == "started");
  assert(ResourceState.stopped.toString == "stopped");
  assert(ResourceState.error.toString == "error");

  assert(toStrings([ResourceState.unknown, ResourceState.error]) == ["unknown", "error"]);
  assert(toResourceState(["unknown", "error"]) == [ResourceState.unknown, ResourceState.error]);
}

/// Category of a metric.
enum MetricCategory {
  cpu,
  memory,
  disk,
  network,
  requests,
  responseTime,
  availability,
  jmx,
  database,
  certificate,
  custom,
}

MetricCategory toMetricCategory(string value) {
  mixin(EnumSwitch("MetricCategory", "custom"));
}

MetricCategory[] toMetricCategories(string[] values)
  => values.map!toMetricCategory.array;

string toString(MetricCategory value)
  => value.to!string;

string[] toStrings(MetricCategory[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("MetricCategory"));

  assert("cpu".toMetricCategory == MetricCategory.cpu);
  assert("memory".toMetricCategory == MetricCategory.memory);
  assert("disk".toMetricCategory == MetricCategory.disk);
  assert("network".toMetricCategory == MetricCategory.network);
  assert("requests".toMetricCategory == MetricCategory.requests);
  assert("responseTime".toMetricCategory == MetricCategory.responseTime);
  assert("availability".toMetricCategory == MetricCategory.availability);
  assert("jmx".toMetricCategory == MetricCategory.jmx);
  assert("database".toMetricCategory == MetricCategory.database);
  assert("certificate".toMetricCategory == MetricCategory.certificate);
  assert("custom".toMetricCategory == MetricCategory.custom);

  assert("unknown".toMetricCategory == MetricCategory.custom);
  assert("".toMetricCategory == MetricCategory.custom);

  assert(MetricCategory.cpu.toString == "cpu");
  assert(MetricCategory.memory.toString == "memory");
  assert(MetricCategory.disk.toString == "disk");
  assert(MetricCategory.network.toString == "network");
  assert(MetricCategory.requests.toString == "requests");
  assert(MetricCategory.responseTime.toString == "responseTime");
  assert(MetricCategory.availability.toString == "availability");
  assert(MetricCategory.jmx.toString == "jmx");
  assert(MetricCategory.database.toString == "database");
  assert(MetricCategory.certificate.toString == "certificate");
  assert(MetricCategory.custom.toString == "custom");

  auto categories = [MetricCategory.cpu, MetricCategory.memory, MetricCategory.disk];
  auto categoryStrings = ["cpu", "memory", "disk"];
  assert(toStrings(categories) == categoryStrings);
  assert(toMetricCategories(categoryStrings) == categories);
}

/// Unit of a metric value.
enum MetricUnit : string {
  percent = "percent",
  bytes_ = "bytes",
  kilobytes = "kilobytes",
  megabytes = "megabytes",
  gigabytes = "gigabytes",
  milliseconds = "milliseconds",
  seconds = "seconds",
  count = "count",
  countPerSecond = "countPerSecond",
  boolean_ = "boolean",
  none = "none",
}
MetricUnit toMetricUnit(string value) {
  switch (value.toLower()) {
    case "percent": return MetricUnit.percent;
    case "bytes": return MetricUnit.bytes_;
    case "kilobytes": return MetricUnit.kilobytes;
    case "megabytes": return MetricUnit.megabytes;
    case "gigabytes": return MetricUnit.gigabytes;
    case "milliseconds": return MetricUnit.milliseconds;
    case "seconds": return MetricUnit.seconds;
    case "count": return MetricUnit.count;
    case "countpersecond": return MetricUnit.countPerSecond;
    case "boolean": return MetricUnit.boolean_;
    default: return MetricUnit.none; // default
  }
}

MetricUnit[] toMetricUnits(string[] values)
  => values.map!(toMetricUnit).array;

string toString(MetricUnit unit)
  => cast(string)unit;

string[] toStrings(MetricUnit[] units)
  => units.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("MetricUnit"));

  assert("percent".toMetricUnit == MetricUnit.percent);
  assert("bytes".toMetricUnit == MetricUnit.bytes_);
  assert("kilobytes".toMetricUnit == MetricUnit.kilobytes);
  assert("megabytes".toMetricUnit == MetricUnit.megabytes);
  assert("gigabytes".toMetricUnit == MetricUnit.gigabytes);
  assert("milliseconds".toMetricUnit == MetricUnit.milliseconds);
  assert("seconds".toMetricUnit == MetricUnit.seconds);
  assert("count".toMetricUnit == MetricUnit.count);
  assert("countpersecond".toMetricUnit == MetricUnit.countPerSecond);
  assert("boolean".toMetricUnit == MetricUnit.boolean_);
  assert("unknown".toMetricUnit == MetricUnit.none);
  assert("".toMetricUnit == MetricUnit.none);

  assert(MetricUnit.percent.toString == "percent");
  assert(MetricUnit.bytes_.toString == "bytes");
  assert(MetricUnit.kilobytes.toString == "kilobytes");
  assert(MetricUnit.megabytes.toString == "megabytes");
  assert(MetricUnit.gigabytes.toString == "gigabytes");
  assert(MetricUnit.milliseconds.toString == "milliseconds");
  assert(MetricUnit.seconds.toString == "seconds");
  assert(MetricUnit.count.toString == "count");
  assert(MetricUnit.countPerSecond.toString == "countpersecond");
  assert(MetricUnit.boolean_.toString == "boolean");
  assert(MetricUnit.none.toString == "none");

  auto units = [MetricUnit.percent, MetricUnit.bytes_, MetricUnit.count];
  auto unitStrings = ["percent", "bytes", "count"];
  assert(toStrings(units) == unitStrings);
  assert(toMetricUnits(unitStrings) == units);
}

/// Aggregation method for metric time-series.
enum AggregationMethod {
  average,
  sum,
  min,
  max,
  last,
  count,
}
AggregationMethod toAggregationMethod(string value) {
  mixin(EnumSwitch("AggregationMethod", "average"));
}

AggregationMethod[] toAggregationMethods(string[] values)
  => values.map!toAggregationMethod.array;

string toString(AggregationMethod value)
  => value.to!string;

string[] toStrings(AggregationMethod[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("AggregationMethod"));

  assert("average".toAggregationMethod == AggregationMethod.average);
  assert("sum".toAggregationMethod == AggregationMethod.sum);
  assert("min".toAggregationMethod == AggregationMethod.min);
  assert("max".toAggregationMethod == AggregationMethod.max);
  assert("last".toAggregationMethod == AggregationMethod.last);
  assert("count".toAggregationMethod == AggregationMethod.count);

  assert("".toAggregationMethod == AggregationMethod.average);
  assert("unknown".toAggregationMethod == AggregationMethod.average);

  assert(AggregationMethod.average.toString == "average");
  assert(AggregationMethod.sum.toString == "sum");
  assert(AggregationMethod.min.toString == "min");
  assert(AggregationMethod.max.toString == "max");
  assert(AggregationMethod.last.toString == "last");
  assert(AggregationMethod.count.toString == "count");

  assert(["average", "count"].toAggregationMethods == [
      AggregationMethod.average, AggregationMethod.count
    ]);
  assert([AggregationMethod.average, AggregationMethod.count].toStrings == [
      "average", "count"
    ]);
}

/// Type of health check.
enum CheckType {
  availability,
  jmx,
  customHttp,
  process,
  database,
  certificate,
}

CheckType toCheckType(string value) {
  mixin(EnumSwitch("CheckType", "availability"));
}

CheckType[] toCheckTypes(string[] values)
  => values.map!toCheckType.array;

string toString(CheckType value)
  => value.to!string;

string[] toStrings(CheckType[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("CheckType"));

  assert("availability".toCheckType == CheckType.availability);
  assert("jmx".toCheckType == CheckType.jmx);
  assert("customHttp".toCheckType == CheckType.customHttp);
  assert("process".toCheckType == CheckType.process);
  assert("database".toCheckType == CheckType.database);
  assert("certificate".toCheckType == CheckType.certificate);

  assert("".toCheckType == CheckType.availability);
  assert("unknown".toCheckType == CheckType.availability);

  assert(CheckType.availability.toString == "availability");
  assert(CheckType.jmx.toString == "jmx");
  assert(CheckType.customHttp.toString == "customHttp");
  assert(CheckType.process.toString == "process");
  assert(CheckType.database.toString == "database");
  assert(CheckType.certificate.toString == "certificate");

  assert(["availability", "database"].toCheckTypes == [
      CheckType.availability, CheckType.database
    ]);
  assert([CheckType.availability, CheckType.database].toStrings == [
      "availability", "database"
    ]);
}

/// Result status of a health check execution.
enum CheckStatus {
  unknown,
  ok,
  warning,
  critical,
  disabled,
}
CheckStatus toCheckStatus(string value) {
  mixin(EnumSwitch("CheckStatus", "unknown"));
}

CheckStatus[] toCheckStatuses(string[] values)
  => values.map!toCheckStatus.array;

string toString(CheckStatus value)
  => value.to!string;

string[] toStrings(CheckStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("CheckStatus"));

  assert("unknown".toCheckStatus == CheckStatus.unknown);
  assert("ok".toCheckStatus == CheckStatus.ok);
  assert("warning".toCheckStatus == CheckStatus.warning);
  assert("critical".toCheckStatus == CheckStatus.critical);
  assert("disabled".toCheckStatus == CheckStatus.disabled);

  assert("".toCheckStatus == CheckStatus.unknown);
  assert("unknownValue".toCheckStatus == CheckStatus.unknown);

  assert(CheckStatus.unknown.toString == "unknown");
  assert(CheckStatus.ok.toString == "ok");
  assert(CheckStatus.warning.toString == "warning");
  assert(CheckStatus.critical.toString == "critical");
  assert(CheckStatus.disabled.toString == "disabled");

  assert(["ok", "critical"].toCheckStatuses == [
      CheckStatus.ok, CheckStatus.critical
    ]);
  assert([CheckStatus.ok, CheckStatus.critical].toStrings == [
      "ok", "critical"
    ]);
}

/// Current state of an alert.
enum AlertState {
  open,
  acknowledged,
  resolved,
  expired,
}

AlertState toAlertState(string value) {
  mixin(EnumSwitch("AlertState", "open"));
}

AlertState[] toAlertStates(string[] values)
  => values.map!toAlertState.array;

string toString(AlertState value)
  => value.to!string;

string[] toStrings(AlertState[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("AlertState"));

  assert("open".toAlertState == AlertState.open);
  assert("acknowledged".toAlertState == AlertState.acknowledged);
  assert("resolved".toAlertState == AlertState.resolved);
  assert("expired".toAlertState == AlertState.expired);

  assert("".toAlertState == AlertState.open);
  assert("unknown".toAlertState == AlertState.open);

  assert(AlertState.open.toString == "open");
  assert(AlertState.acknowledged.toString == "acknowledged");
  assert(AlertState.resolved.toString == "resolved");
  assert(AlertState.expired.toString == "expired");

  assert(["open", "resolved"].toAlertStates == [
      AlertState.open, AlertState.resolved
    ]);
  assert([AlertState.open, AlertState.resolved].toStrings == [
      "open", "resolved"
    ]);
}

/// Type of comparison for alert rule thresholds.
enum ThresholdOperator {
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  equal,
  notEqual,
}
ThresholdOperator toThresholdOperator(string value) {
  mixin(EnumSwitch("ThresholdOperator", "greaterThan"));
}

ThresholdOperator[] toThresholdOperators(string[] values)
  => values.map!toThresholdOperator.array;

string toString(ThresholdOperator value)
  => value.to!string;

string[] toStrings(ThresholdOperator[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ThresholdOperator"));

  assert("greaterThan".toThresholdOperator == ThresholdOperator.greaterThan);
  assert("greaterOrEqual".toThresholdOperator == ThresholdOperator.greaterOrEqual);
  assert("lessThan".toThresholdOperator == ThresholdOperator.lessThan);
  assert("lessOrEqual".toThresholdOperator == ThresholdOperator.lessOrEqual);
  assert("equal".toThresholdOperator == ThresholdOperator.equal);
  assert("notEqual".toThresholdOperator == ThresholdOperator.notEqual);

  assert("".toThresholdOperator == ThresholdOperator.greaterThan);
  assert("unknown".toThresholdOperator == ThresholdOperator.greaterThan);

  assert(ThresholdOperator.greaterThan.toString == "greaterThan");
  assert(ThresholdOperator.greaterOrEqual.toString == "greaterOrEqual");
  assert(ThresholdOperator.lessThan.toString == "lessThan");
  assert(ThresholdOperator.lessOrEqual.toString == "lessOrEqual");
  assert(ThresholdOperator.equal.toString == "equal");
  assert(ThresholdOperator.notEqual.toString == "notEqual");

  assert(["greaterThan", "equal"].toThresholdOperators == [
      ThresholdOperator.greaterThan, ThresholdOperator.equal
    ]);
  assert([ThresholdOperator.greaterThan, ThresholdOperator.equal].toStrings == [
      "greaterThan", "equal"
    ]);
}

/// Type of notification channel.
enum NotificationChannelType {
  email,
  webhook,
  onPremise,
}
NotificationChannelType toNotificationChannelType(string value) {
  switch (value.toLower()) {
    case "email": return NotificationChannelType.email;
    case "webhook": return NotificationChannelType.webhook;
    case "onpremise": return NotificationChannelType.onPremise;
    default: return NotificationChannelType.email; // default
  }
}
/// State of a notification channel.
enum ChannelState {
  active, // default - active and can be used for notifications
  inactive, // channel is inactive and won't be used for notifications
  error, // channel encountered an error and won't be used for notifications
}

ChannelState toChannelState(string value) {
  mixin(EnumSwitch("ChannelState", "active"));
}

ChannelState[] toChannelStates(string[] values)
  => values.map!toChannelState.array;

string toString(ChannelState value)
  => value.to!string;

string[] toStrings(ChannelState[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ChannelState"));

  assert("active".toChannelState == ChannelState.active);
  assert("inactive".toChannelState == ChannelState.inactive);
  assert("error".toChannelState == ChannelState.error);

  assert("".toChannelState == ChannelState.active);
  assert("unknown".toChannelState == ChannelState.active);

  assert(ChannelState.active.toString == "active");
  assert(ChannelState.inactive.toString == "inactive");
  assert(ChannelState.error.toString == "error");

  assert(["active", "error"].toChannelStates == [
      ChannelState.active, ChannelState.error
    ]);
  assert([ChannelState.active, ChannelState.error].toStrings == [
      "active", "error"
    ]);
}

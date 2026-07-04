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
string[] toString(ResourceType[] values) {
  return values.map!(toString).array;
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

  assert(toString([ResourceType.javaApplication, ResourceType.service]) == ["javaApplication", "service"]);
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
string[] toString(ResourceState[] states) {
  return states.map!(toString).array;
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

  assert(toString([ResourceState.unknown, ResourceState.error]) == ["unknown", "error"]);
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
  switch (value.toLower()) {
    case "cpu": return MetricCategory.cpu;
    case "memory": return MetricCategory.memory;
    case "disk": return MetricCategory.disk;
    case "network": return MetricCategory.network;
    case "requests": return MetricCategory.requests;
    case "responsetime": return MetricCategory.responseTime;
    case "availability": return MetricCategory.availability;
    case "jmx": return MetricCategory.jmx;
    case "database": return MetricCategory.database;
    case "certificate": return MetricCategory.certificate;
    default: return MetricCategory.custom; // default
  }
}
/// Unit of a metric value.
enum MetricUnit {
  percent,
  bytes_,
  kilobytes,
  megabytes,
  gigabytes,
  milliseconds,
  seconds,
  count,
  countPerSecond,
  boolean_,
  none,
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
  switch (value.toLower()) {
    case "average": return AggregationMethod.average;
    case "sum": return AggregationMethod.sum;
    case "min": return AggregationMethod.min;
    case "max": return AggregationMethod.max;
    case "last": return AggregationMethod.last;
    case "count": return AggregationMethod.count;
    default: return AggregationMethod.average; // default
  }
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
  switch (value.toLower()) {
    case "availability": return CheckType.availability;
    case "jmx": return CheckType.jmx;
    case "customhttp": return CheckType.customHttp;
    case "process": return CheckType.process;
    case "database": return CheckType.database;
    case "certificate": return CheckType.certificate;
    default: return CheckType.availability; // default
  }
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
  switch (value.toLower()) {
    case "unknown": return CheckStatus.unknown;
    case "ok": return CheckStatus.ok;
    case "warning": return CheckStatus.warning;
    case "critical": return CheckStatus.critical;
    case "disabled": return CheckStatus.disabled;
    default: return CheckStatus.unknown; // default
  }
}

/// Current state of an alert.
enum AlertState {
  open,
  acknowledged,
  resolved,
  expired,
}
AlertState toAlertState(string value) {
  switch (value.toLower()) {
    case "open": return AlertState.open;
    case "acknowledged": return AlertState.acknowledged;
    case "resolved": return AlertState.resolved;
    case "expired": return AlertState.expired;
    default: return AlertState.open; // default
  }
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
  switch (value.toLower()) {
    case "greaterthan": return ThresholdOperator.greaterThan;
    case "greaterorequal": return ThresholdOperator.greaterOrEqual;
    case "lessthan": return ThresholdOperator.lessThan;
    case "lessorequal": return ThresholdOperator.lessOrEqual;
    case "equal": return ThresholdOperator.equal;
    case "notequal": return ThresholdOperator.notEqual;
    default: return ThresholdOperator.greaterThan; // default
  }
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


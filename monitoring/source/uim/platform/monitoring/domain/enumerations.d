module uim.platform.monitoring.domain.enumerations;
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
ResourceType toResourceType(string s) {
  switch (s.toLower()) {
    case "javaapplication": return ResourceType.javaApplication;
    case "html5application": return ResourceType.html5Application;
    case "hanaxsapplication": return ResourceType.hanaXsApplication;
    case "databasesystem": return ResourceType.databaseSystem;
    case "nodeapplication": return ResourceType.nodeApplication;
    case "customapplication": return ResourceType.customApplication;
    case "service": return ResourceType.service;
    default: return ResourceType.customApplication; // default
  }
}
/// Current state of a monitored resource.
enum ResourceState {
  unknown,
  started,
  stopped,
  error,
}
ResourceState toResourceState(string s) {
  switch (s.toLower()) {
    case "unknown": return ResourceState.unknown;
    case "started": return ResourceState.started;
    case "stopped": return ResourceState.stopped;
    case "error": return ResourceState.error;
    default: return ResourceState.unknown; // default
  }
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
MetricCategory toMetricCategory(string s) {
  switch (s.toLower()) {
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
MetricUnit toMetricUnit(string s) {
  switch (s.toLower()) {
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
AggregationMethod toAggregationMethod(string s) {
  switch (s.toLower()) {
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
CheckType toCheckType(string s) {
  switch (s.toLower()) {
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
CheckStatus toCheckStatus(string s) {
  switch (s.toLower()) {
    case "unknown": return CheckStatus.unknown;
    case "ok": return CheckStatus.ok;
    case "warning": return CheckStatus.warning;
    case "critical": return CheckStatus.critical;
    case "disabled": return CheckStatus.disabled;
    default: return CheckStatus.unknown; // default
  }
}
/// Severity level for alerts.
enum AlertSeverity {
  info,
  warning,
  critical,
  fatal,
}
AlertSeverity toAlertSeverity(string s) {
  switch (s.toLower()) {
    case "info": return AlertSeverity.info;
    case "warning": return AlertSeverity.warning;
    case "critical": return AlertSeverity.critical;
    case "fatal": return AlertSeverity.fatal;
    default: return AlertSeverity.info; // default
  }
}
/// Current state of an alert.
enum AlertState {
  open,
  acknowledged,
  resolved,
  expired,
}
AlertState toAlertState(string s) {
  switch (s.toLower()) {
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
ThresholdOperator toThresholdOperator(string s) {
  switch (s.toLower()) {
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
NotificationChannelType toNotificationChannelType(string s) {
  switch (s.toLower()) {
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
ChannelState toChannelState(string s) {
  switch (s.toLower()) {
    case "active": return ChannelState.active;
    case "inactive": return ChannelState.inactive;
    case "error": return ChannelState.error;
    default: return ChannelState.active; // default
  }
}


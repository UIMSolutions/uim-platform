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

/// Current state of a monitored resource.
enum ResourceState {
  started,
  stopped,
  error,
  unknown,
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

/// Aggregation method for metric time-series.
enum AggregationMethod {
  average,
  sum,
  min,
  max,
  last,
  count,
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

/// Result status of a health check execution.
enum CheckStatus {
  ok,
  warning,
  critical,
  unknown,
  disabled,
}

/// Severity level for alerts.
enum AlertSeverity {
  info,
  warning,
  critical,
  fatal,
}

/// Current state of an alert.
enum AlertState {
  open,
  acknowledged,
  resolved,
  expired,
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

/// Type of notification channel.
enum NotificationChannelType {
  email,
  webhook,
  onPremise,
}

/// State of a notification channel.
enum ChannelState {
  active,
  inactive,
  error,
}

  static AlertState parseAlertState(string state) {
    switch (state) {
    case "acknowledged":
      return AlertState.acknowledged;
    case "resolved":
      return AlertState.resolved;
    case "expired":
      return AlertState.expired;
    default:
      return AlertState.open;
    }
  }

  static AlertSeverity parseSeverity(string severity) {
    switch (severity) {
    case "info":
      return AlertSeverity.info;
    case "critical":
      return AlertSeverity.critical;
    case "fatal":
      return AlertSeverity.fatal;
    default:
      return AlertSeverity.warning;
    }
  }
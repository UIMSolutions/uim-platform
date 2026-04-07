/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.types;

/// Unique identifier type aliases for type safety.
alias MetricId = string;
alias MetricDefinitionId = string;
alias HealthCheckId = string;
alias HealthCheckResultId = string;
alias AlertRuleId = string;
alias AlertId = string;
alias NotificationChannelId = string;
alias MonitoredResourceId = string;

alias SubaccountId = string;

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
enum ChannelType {
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

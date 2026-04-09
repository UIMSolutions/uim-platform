/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct MetricId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
///
unittest {
  auto id1 = MetricId("metric-123");
  auto id2 = MetricId("metric-123");
  auto id3 = MetricId("metric-456");

  assert(id1 == id2);
  assert(id1 != id3);
} 
struct MetricDefinitionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct HealthCheckId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct HealthCheckResultId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct AlertRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct AlertId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct NotificationChannelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct MonitoredResourceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

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

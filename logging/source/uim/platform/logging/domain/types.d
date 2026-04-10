/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.types;

struct LogEntryId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct LogStreamId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TraceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SpanId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DashboardId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PanelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RetentionPolicyId {
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

struct PipelineId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct IngestionTokenId = string;
struct TenantId = string;
struct SubaccountId = string;

enum LogLevel {
  trace,
  debug_,
  info,
  warn,
  error,
  fatal,
}

enum LogSourceType {
  application,
  request,
  system,
  custom,
  cloudFoundry,
  kyma,
  kubernetes,
}

enum SpanKind {
  client,
  server,
  producer,
  consumer,
  internal,
}

enum SpanStatus {
  ok,
  error,
  timeout,
  unset,
}

enum PanelType {
  lineChart,
  barChart,
  pieChart,
  table,
  counter,
  logView,
  traceView,
  heatmap,
}

enum DataType {
  logs,
  metrics,
  traces,
  all,
}

enum AlertCondition {
  contains,
  regex,
  threshold,
  absence,
  rateChange,
}

enum AlertSeverity {
  info,
  warning,
  critical,
  fatal,
}

enum AlertState {
  open,
  acknowledged,
  resolved,
  expired,
}

enum ThresholdOperator {
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  equal,
  notEqual,
}

enum ChannelType {
  email,
  webhook,
  slack,
}

enum ChannelState {
  active,
  inactive,
  error,
}

enum PipelineFormat {
  json,
  otel,
  syslog,
  plaintext,
}

enum PipelineSourceType {
  cloudFoundry,
  kyma,
  kubernetes,
  otel,
  custom,
}

enum ProcessorType {
  filter,
  transform,
  enrich,
  sample,
  redact,
}

enum TokenScope {
  ingestLogs,
  ingestMetrics,
  ingestTraces,
  readLogs,
  readMetrics,
  readTraces,
  admin,
}

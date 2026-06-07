module uim.platform.logging.domain.enumerations;
import uim.platform.logging;

// mixin(ShowModule!());

@safe:

// Type of log source, used to categorize and filter logs.
enum LogSourceType {
  custom,
  application,
  request,
  system,
  cloudFoundry,
  kyma,
  kubernetes,
}

enum SpanKind {
  internal,
  client,
  server,
  producer,
  consumer,
}
// Status of a trace span, determined by the presence of errors or timeouts.
enum SpanStatus {
  unset,
  ok,
  error,
  timeout,
}

enum PanelType {
  logView,
  lineChart,
  barChart,
  pieChart,
  table,
  counter,
  traceView,
  heatmap,
}

enum DataType {
  all,
  logs,
  metrics,
  traces,
}
// Type of log query
enum LogQueryType {
  logs,
  metrics,
  traces,
  all,
}
// Type of alert condition
enum AlertCondition {
  contains,
  regex,
  threshold,
  absence,
  rateChange,
}

// Current state of an alert.
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

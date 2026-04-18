module uim.platform.logging.domain.enumerations;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
enum LoggingLevel {
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

  LogSourceType toLogSourceType(string s) {
    switch (s) {
    case "application":
      return LogSourceType.application;
    case "request":
      return LogSourceType.request;
    case "system":
      return LogSourceType.system;
    case "cloudFoundry":
      return LogSourceType.cloudFoundry;
    case "kyma":
      return LogSourceType.kyma;
    case "kubernetes":
      return LogSourceType.kubernetes;
    default:
      return LogSourceType.custom;
    }
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

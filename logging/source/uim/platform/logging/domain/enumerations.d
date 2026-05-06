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

private static AlertCondition parseCondition(string condition) {
    switch (condition) {
    case "contains":
      return AlertCondition.contains;
    case "regex":
      return AlertCondition.regex;
    case "threshold":
      return AlertCondition.threshold;
    case "absence":
      return AlertCondition.absence;
    case "rateChange":
      return AlertCondition.rateChange;
    default:
      return AlertCondition.contains;
    }
  }

  private static ThresholdOperator parseOperator(string s) {
    switch (s) {
    case "greaterThan":
      return ThresholdOperator.greaterThan;
    case "greaterOrEqual":
      return ThresholdOperator.greaterOrEqual;
    case "lessThan":
      return ThresholdOperator.lessThan;
    case "lessOrEqual":
      return ThresholdOperator.lessOrEqual;
    case "equal":
      return ThresholdOperator.equal;
    case "notEqual":
      return ThresholdOperator.notEqual;
    default:
      return ThresholdOperator.greaterThan;
    }
  }

  private static AlertSeverity parseSeverity(string s) {
    switch (s) {
    case "info":
      return AlertSeverity.info;
    case "warning":
      return AlertSeverity.warning;
    case "critical":
      return AlertSeverity.critical;
    case "fatal":
      return AlertSeverity.fatal;
    default:
      return AlertSeverity.warning;
    }
  }
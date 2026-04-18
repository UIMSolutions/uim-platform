/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.services.log_parser;

// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct ParseResult {
  bool valid;
  string[] errors;
  LogEntry entry;
}

struct LogParser {
  static ParseResult validate(const ref LogEntry entry) {
    string[] errors;

    if (entry.tenantId.isEmpty)
      errors ~= "Tenant ID is required";
    if (entry.message.length == 0)
      errors ~= "Log message is required";
    if (entry.timestamp <= 0)
      errors ~= "Timestamp must be positive";

    ParseResult result;
    result.valid = errors.length == 0;
    result.errors = errors;
    return result;
  }

  static LoggingLevel parseLevel(string levelStr) {
    switch (levelStr) {
    case "trace":
      return LoggingLevel.trace;
    case "debug":
      return LoggingLevel.debug_;
    case "info":
      return LoggingLevel.info;
    case "warn", "warning":
      return LoggingLevel.warn;
    case "error":
      return LoggingLevel.error;
    case "fatal":
      return LoggingLevel.fatal;
    default:
      return LoggingLevel.info;
    }
  }

  static string levelToString(LoggingLevel level) {
    final switch (level) {
    case LoggingLevel.trace:
      return "trace";
    case LoggingLevel.debug_:
      return "debug";
    case LoggingLevel.info:
      return "info";
    case LoggingLevel.warn:
      return "warn";
    case LoggingLevel.error:
      return "error";
    case LoggingLevel.fatal:
      return "fatal";
    }
  }
}

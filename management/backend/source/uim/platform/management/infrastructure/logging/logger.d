/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.logging.logger;

import vibe.core.log : LogLevel, setLogLevel;
import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Map a textual level ("trace", "debug", "info", "warn", "error", "none") to vibe.d's log level.
LogLevel parseLogLevel(string level) pure nothrow {
  switch (level) {
  case "trace":
    return LogLevel.trace;
  case "debug":
    return LogLevel.debug_;
  case "warn", "warning":
    return LogLevel.warn;
  case "error":
    return LogLevel.error;
  case "none", "off":
    return LogLevel.none;
  default:
    return LogLevel.info;
  }
}

/// Configure the process-wide technical logging.
void configureLogging(string level) {
  (() @trusted => setLogLevel(parseLogLevel(level)))();
}

/// Messaging adapter that writes platform events to the technical log.
/// Replace with an Event Mesh / Kafka publisher for production use.
class LogEventPublisher : IPlatformEventPublisher {
  void publish(string topic, Json payload) {
    logDebug("management event %s: %s", topic, payload.toString);
  }
}

///
unittest {
  mixin(ShowTest!("parseLogLevel"));

  assert(parseLogLevel("debug") == LogLevel.debug_);
  assert(parseLogLevel("unknown") == LogLevel.info);
}

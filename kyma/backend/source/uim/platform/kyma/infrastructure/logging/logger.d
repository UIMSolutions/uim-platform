/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.logging.logger;

import vibe.core.log : LogLevel, setLogLevel;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Map a textual level ("debug", "info", "warn", "error", "none") to vibe.d's log level.
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

/// Messaging adapter that writes domain events to the technical log.
/// Replace with an Event Mesh / NATS publisher for production use.
class LogEventPublisher : IKymaEventPublisher {
  void publish(string topic, Json payload) {
    logDebug("kyma event %s: %s", topic, payload.toString);
  }
}

///
unittest {
  assert(parseLogLevel("debug") == LogLevel.debug_);
  assert(parseLogLevel("unknown") == LogLevel.info);
}

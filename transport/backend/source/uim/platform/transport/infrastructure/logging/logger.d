/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.logging.logger;

import vibe.core.log : LogLevel, setLogLevel;
import uim.platform.transport;

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

/// Messaging adapter writing transport events to the technical log.
/// Replace with an Event Mesh / Kafka publisher for production use.
class LogEventPublisher : ITransportEventPublisher {
  void publish(string topic, Json payload) {
    logDebug("transport event %s: %s", topic, payload.toString);
  }
}

/// Messaging adapter that keeps events in memory (tests).
class MemoryEventPublisher : ITransportEventPublisher {
  string[] topics;
  Json[] payloads;

  void publish(string topic, Json payload) {
    topics ~= topic;
    payloads ~= payload;
  }
}

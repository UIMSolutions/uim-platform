/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structured (JSON line) logging of service events and decisions.
module uim.platform.authorization.infrastructure.logging.events;

import vibe.core.log : LogLevel, setLogLevel;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

enum string logComponent = "uim-authorization";

void logAuthorizationEvent(string level, string message, Json fields = Json(null)) {
  logStructured(level, logComponent, message, fields);
}

/// "trace" | "debug" | "info" | "warn" | "error" | "none"
void configureLogging(string level) @trusted {
  switch (level.toLower) {
  case "trace":
    setLogLevel(LogLevel.trace);
    break;
  case "debug":
    setLogLevel(LogLevel.debug_);
    break;
  case "warn", "warning":
    setLogLevel(LogLevel.warn);
    break;
  case "error":
    setLogLevel(LogLevel.error);
    break;
  case "none", "off":
    setLogLevel(LogLevel.none);
    break;
  default:
    setLogLevel(LogLevel.info);
  }
}

/// Messaging adapter: decisions go to the structured log (replace with an
/// Event Mesh / Kafka / SIEM publisher in production).
class LogDecisionPublisher : IDecisionPublisher {
  void publish(const DecisionRecord d) {
    logAuthorizationEvent("debug", "authorization decision", Json([
        "tenant": Json(d.tenantId.value), "principal": Json(d.principalId),
        "application": Json(d.applicationId.value), "resource": Json(d.resource), "action": Json(d.action),
        "allowed": Json(d.allowed), "channel": Json(d.channel)
      ]));
  }
}

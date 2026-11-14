/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.logging.logger;

import vibe.core.log : LogLevel, setLogLevel;
import uim.platform.identity_authentication;

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

/// Messaging adapter that writes the security events (audit trail) to the
/// technical log. Replace with an Event Mesh / audit log publisher in production.
class LogEventPublisher : IIdentityEventPublisher {
  void publish(string topic, Json payload) {
    if (topic == IdentityTopics.loginFailed || topic == IdentityTopics.userLocked)
      logWarn("audit %s: %s", topic, payload.toString);
    else
      logInfo("audit %s: %s", topic, payload.toString);
  }
}

/// OTP delivery for development: writes the message to the log.
class LogOtpSender : IOtpSender {
  void send(MfaType channel, string destination, string message) {
    logInfo("[otp:%s] to %s: %s", enumValue(channel), destination, message);
  }
}

///
unittest {
  mixin(ShowTest!("parseLogLevel"));

  assert(parseLogLevel("debug") == LogLevel.debug_);
  assert(parseLogLevel("unknown") == LogLevel.info);
}

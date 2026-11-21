/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structured (JSON line) logging of service events and the logging
/// adapter of the event publisher port. Secret material is never logged.
module uim.platform.ai_core.infrastructure.logging.aicore;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum string logComponent = "uim-ai-core";

void logServiceEvent(string level, string message, Json fields = Json(null)) {
  logStructured(level, logComponent, message, fields);
}

/// Writes every lifecycle event as a structured log line and keeps the
/// most recent ones in memory (for diagnostics and tests).
class LoggingEventPublisher : IAiCoreEventPublisher {
  protected Json[] recent;
  size_t capacity = 200;
  bool log = true;

  void publish(string type, TenantId t, string subject, Json data) nothrow {
    try {
      auto e = Json.emptyObject;
      e["type"] = type;
      e["tenantId"] = t.value;
      e["subject"] = subject;
      e["data"] = data.type == Json.Type.undefined ? Json.emptyObject : data;
      e["time"] = isoTimeText(nowStdTime());
      recent ~= e;
      if (recent.length > capacity)
        recent = recent[$ - capacity .. $];
      if (log)
        logServiceEvent("info", type, e);
    } catch (Exception) {
    }
  }

  /// The most recent events (oldest first).
  Json[] events() {
    return recent.dup;
  }
}

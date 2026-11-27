/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structured (JSON line) logging of service events and the logging
/// adapter of the audit trail port.
module uim.platform.datasphere.infrastructure.logging.audit;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum string logComponent = "uim-datasphere";

void logServiceEvent(string level, string message, Json fields = Json(null)) {
  logStructured(level, logComponent, message, fields);
}

/// Writes every audit entry as a structured log line and keeps the most
/// recent ones in memory (diagnostics and tests).
class LoggingAuditTrail : IAuditTrail {
  protected Json[] recent;
  size_t capacity = 200;
  bool log = true;

  void record(string type, TenantId t, string subject, Json data) nothrow {
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
        logServiceEvent(type.endsWith(".failed") || type.endsWith(".locked") ? "warning" : "info", type, e);
    } catch (Exception) {
    }
  }

  /// The most recent entries (oldest first).
  Json[] entries() {
    return recent.dup;
  }

  /// Types of the recent entries (tests).
  string[] types() {
    return recent.map!(e => e["type"].get!string).array;
  }
}

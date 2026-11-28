/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structured (JSON line) logging of service events and the logging
/// adapter of the audit trail port: every entry is written as a log line,
/// kept in a small in-memory ring (diagnostics, tests) and — unless
/// persistAuditLog is off — stored in the audit log of the administration.
module uim.platform.ai_launchpad.infrastructure.logging.audit;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string logComponent = "uim-ai-launchpad";

void logServiceEvent(string level, string message, Json fields = Json(null)) {
  logStructured(level, logComponent, message, fields);
}

/// "resourceGroup" → "Resource group", "defaultsRestored" → "defaults restored"
string eventWords(string name, bool capital) pure {
  import std.uni : isUpper, toLower, toUpper;

  string words;
  foreach (i, dchar c; name) {
    if (i > 0 && isUpper(c)) {
      words ~= ' ';
      words ~= toLower(c);
    } else
      words ~= i == 0 && capital ? toUpper(c) : c;
  }
  return words;
}

/// A readable message: "execution.stopped", "e1" → "Execution 'e1' stopped".
string describeEvent(string type, string subject, Json data) @trusted {
  auto dot = type.indexOf('.');
  auto what = dot > 0 ? eventWords(type[0 .. dot], true) : eventWords(type, true);
  auto action = dot > 0 ? eventWords(type[dot + 1 .. $], false) : "";
  auto text = what ~ (subject.length ? " '" ~ subject ~ "'" : "") ~ (action.length ? " " ~ action : "");
  if (data.type == Json.Type.object)
    foreach (key; ["reason", "message", "summary", "fields"])
      if (key in data && data[key].type == Json.Type.string && data[key].get!string.length) {
        text ~= " (" ~ (key == "fields" ? "changed: " : "") ~ data[key].get!string ~ ")";
        break;
      }
  return text.length > 2000 ? text[0 .. 2000] : text;
}

class LoggingAuditTrail : IAuditTrail {
  protected Json[] recent;
  protected ILogEntryRepository store; /// null: no persistent audit log
  protected IClock clock;
  size_t capacity = 200;
  bool log = true;
  long persistErrors;
  private long lastTime; /// strictly increasing entry times keep the log in order

  this(ILogEntryRepository store = null, IClock clock = null) {
    this.store = store;
    this.clock = clock;
  }

  void record(string type, TenantId t, UserId actor, string subject, Json data) nothrow {
    try {
      auto details = data.type == Json.Type.undefined || data.type == Json.Type.null_ ? Json.emptyObject : data;
      auto message = describeEvent(type, subject, details);
      auto severity = severityOf(type);
      auto e = Json.emptyObject;
      e["type"] = type;
      e["tenantId"] = t.value;
      e["actor"] = actor.value;
      e["subject"] = subject;
      e["message"] = message;
      e["data"] = details;
      e["time"] = isoTimeText(nowStdTime());
      recent ~= e;
      if (recent.length > capacity)
        recent = recent[$ - capacity .. $];
      if (log)
        logServiceEvent(severity == LogSeverity.info ? "info" : severity == LogSeverity.warning ? "warning" : "error", type, e);
      if (store !is null && !t.isNull) {
        LogEntry entry;
        entry.id = LogEntryId(newResourceId());
        entry.tenantId = t;
        auto at = clock !is null ? clock.now : nowStdTime();
        if (at <= lastTime)
          at = lastTime + 1;
        lastTime = at;
        entry.createdAt = at;
        entry.updatedAt = entry.createdAt;
        entry.createdBy = actor;
        entry.updatedBy = actor;
        entry.category = categoryOf(type);
        entry.severity = severity;
        entry.eventType = type.length > 100 ? type[0 .. 100] : type;
        entry.subject = subject.length > 256 ? subject[0 .. 256] : subject;
        entry.message = message;
        auto text = details.toString;
        entry.details = text.length > 8000 ? text[0 .. 8000] : text;
        store.save(entry);
      }
    } catch (Exception) {
      persistErrors++;
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

///
unittest {
  assert(describeEvent("execution.stopped", "e1", Json.emptyObject) == "Execution 'e1' stopped");
  assert(describeEvent("resourceGroup.created", "default", Json.emptyObject) == "Resource group 'default' created");
  assert(describeEvent("login.failed", "ada", Json(["reason": Json("password")])) == "Login 'ada' failed (password)");
  assert(describeEvent("tile.defaultsRestored", "t", Json.emptyObject) == "Tile 't' defaults restored");
}

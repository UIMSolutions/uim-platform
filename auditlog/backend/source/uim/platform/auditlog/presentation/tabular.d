/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tabular projections of the domain entities, shared by the text based
/// presentation adapters (CLI tables and GtkD list views).
module uim.platform.auditlog.presentation.tabular;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// A table: column headers + string cells.
struct Table {
  string[] headers;
  string[][] rows;

  size_t length() const {
    return rows.length;
  }

  /// Render as aligned plain text (columns capped at maxWidth characters).
  string render(size_t maxWidth = 48) const {
    import std.array : appender;
    import std.utf : count;

    auto widths = headers.map!(h => h.count).array;
    foreach (r; rows)
      foreach (i, c; r)
        if (i < widths.length)
          widths[i] = max(widths[i], min(c.count, maxWidth));

    string cell(string s, size_t w) {
      auto n = s.count;
      if (n > w) {
        import std.range : take;
        import std.conv : text;

        return s.take(w - 1).text ~ "…";
      }
      return s ~ ' '.repeat(w - n).array.idup;
    }

    auto buf = appender!string;
    void line(const string[] cells) {
      foreach (i, w; widths)
        buf.put((i ? "  " : "") ~ cell(i < cells.length ? cells[i] : "", w));
      buf.put("\n");
    }

    line(headers);
    line(widths.map!(w => '-'.repeat(w).array.idup).array);
    foreach (r; rows)
      line(r);
    return buf.data;
  }
}

/// stdTime → "2026-11-09 10:00:00" (UTC); 0 → "".
string formatCliTime(long stdTime) {
  if (stdTime <= 0)
    return "";
  try {
    auto t = SysTime(stdTime, UTC());
    t.fracSecs = Duration.zero;
    return t.toISOExtString.replace("T", " ").stripRight("Z");
  } catch (Exception) {
    return "";
  }
}

/// "2026-11-09", "2026-11-09T10:00:00Z" or "2026-11-09 10:00:00" → stdTime; "" → 0.
long parseCliTime(string value) {
  auto v = value.strip;
  if (v.length == 0)
    return 0;
  if (v.length == 10)
    v ~= "T00:00:00";
  v = v.replace(" ", "T");
  if (!v.endsWith("Z") && !v[10 .. $].canFind('+') && !v[10 .. $].canFind('-'))
    v ~= "Z";
  return SysTime.fromISOExtString(v).stdTime;
}

private string categoryNames(const AuditCategory[] categories) {
  return categories.map!(c => c.to!string).join(", ");
}

Table auditLogTable(const AuditLogEntry[] entries) {
  Table t;
  t.headers = ["Time", "Category", "Severity", "Action", "Outcome", "User", "Object", "Message", "ID"];
  foreach (e; entries)
    t.rows ~= [
      formatCliTime(e.timestamp), e.category.to!string, e.severity.to!string,
      cast(string) e.action, e.outcome.to!string,
      e.userName.length ? e.userName : e.userId.value,
      e.objectType.length ? e.objectType ~ ":" ~ e.objectId : e.objectId,
      e.message, e.id.value
    ];
  return t;
}

Table securityEventTable(const SecurityEvent[] events) {
  Table t;
  t.headers = ["Time", "Event", "User", "Outcome", "IP", "Risk", "Failure Reason", "ID"];
  foreach (e; events)
    t.rows ~= [
      formatCliTime(e.timestamp), e.eventType, e.userName.length ? e.userName : e.userId.value,
      e.outcome.to!string, e.ipAddress, e.riskLevel, e.failureReason, e.id.value
    ];
  return t;
}

Table dataAccessTable(const DataAccessLog[] logs) {
  Table t;
  t.headers = ["Time", "Accessed By", "Data Subject", "Object", "Fields", "Purpose", "Channel", "ID"];
  foreach (e; logs)
    t.rows ~= [
      formatCliTime(e.timestamp), e.accessedBy.value, e.dataSubject,
      e.dataObjectType ~ ":" ~ e.dataObjectId, e.accessedFields.join(", "),
      e.purpose, e.channel, e.id.value
    ];
  return t;
}

Table configChangeTable(const ConfigChangeLog[] logs) {
  Table t;
  t.headers = ["Time", "Changed By", "Type", "Object", "Changes", "Reason", "ID"];
  foreach (e; logs)
    t.rows ~= [
      formatCliTime(e.timestamp), e.changedBy.value, e.configType, e.configObjectId,
      e.changes.map!(c => c.name ~ ": " ~ c.oldValue ~ " → " ~ c.newValue).join("; "),
      e.reason, e.id.value
    ];
  return t;
}

Table retentionTable(const RetentionPolicy[] policies) {
  Table t;
  t.headers = ["Name", "Days", "Categories", "Status", "Default", "ID"];
  foreach (p; policies)
    t.rows ~= [
      p.name, p.retentionDays.to!string, categoryNames(p.categories),
      p.status.to!string, p.isDefault ? "yes" : "", p.id.value
    ];
  return t;
}

Table exportTable(const ExportJob[] jobs) {
  Table t;
  t.headers = ["Created", "Format", "Status", "Records", "Categories", "Requested By", "ID"];
  foreach (j; jobs)
    t.rows ~= [
      formatCliTime(j.createdAt), j.format_.to!string, j.status.to!string,
      j.totalRecords.to!string, categoryNames(j.categories), j.requestedBy.value, j.id.value
    ];
  return t;
}

Table auditConfigTable(const AuditConfig[] configs) {
  Table t;
  t.headers = ["Name", "Status", "Data Access", "Data Mod.", "Security", "Config", "Masking", "Min. Severity", "ID"];
  string yn(bool b) {
    return b ? "on" : "off";
  }

  foreach (c; configs)
    t.rows ~= [
      c.name, c.status.to!string, yn(c.logDataAccess), yn(c.logDataModification),
      yn(c.logSecurityEvents), yn(c.logConfigurationChanges), yn(c.enableDataMasking),
      c.minimumSeverity.to!string, c.id.value
    ];
  return t;
}

/// Key/value view of the statistics.
Table statisticsTable(const AuditStatistics s) {
  Table t;
  t.headers = ["Figure", "Value"];
  t.rows ~= ["Tenant", s.tenantId.value];
  t.rows ~= ["Audit entries", s.totalEntries.to!string];
  t.rows ~= ["Security events", s.securityEvents.to!string];
  t.rows ~= ["Failed security events", s.failedLogins.to!string];
  t.rows ~= ["Data accesses", s.dataAccessLogs.to!string];
  t.rows ~= ["Configuration changes", s.configChanges.to!string];
  t.rows ~= ["Retention policies", s.retentionPolicies.to!string];
  t.rows ~= ["Export jobs", s.exportJobs.to!string];
  t.rows ~= ["Effective retention (days)", s.retentionDays.to!string];
  t.rows ~= ["Last entry", formatCliTime(s.lastEntryAt)];
  foreach (k; s.byCategory.keys.sort)
    t.rows ~= ["Category " ~ k, s.byCategory[k].to!string];
  foreach (k; s.bySeverity.keys.sort)
    t.rows ~= ["Severity " ~ k, s.bySeverity[k].to!string];
  return t;
}

///
unittest {
  mixin(ShowTest!("Table"));

  Table t;
  t.headers = ["A", "B"];
  t.rows ~= ["x", "longer"];
  auto text = t.render();
  assert(text.canFind("A  B"));
  assert(text.canFind("x  longer"));

  assert(formatCliTime(0) == "");
  auto st = parseCliTime("2026-11-09");
  assert(formatCliTime(st) == "2026-11-09 00:00:00");
  assert(parseCliTime("2026-11-09 10:30:00") > st);
}

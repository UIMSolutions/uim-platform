/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tabular projections of the domain entities, shared by the text based
/// presentation adapters (CLI tables and GtkD list views).
module uim.platform.transport.presentation.tabular;

import core.time : Duration;
import std.datetime.systime : SysTime;
import std.datetime.timezone : UTC;
import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// A table: column headers + string cells. By convention the last column is the ID.
struct Table {
  string[] headers;
  string[][] rows;

  size_t length() const {
    return rows.length;
  }

  /// Render as aligned plain text (columns capped at maxWidth characters).
  string render(size_t maxWidth = 40) const {
    import std.array : appender;
    import std.utf : count;
    import std.range : take;
    import std.conv : text;

    auto widths = headers.map!(h => h.count).array;
    foreach (r; rows)
      foreach (i, c; r)
        if (i < widths.length)
          widths[i] = max(widths[i], min(c.count, maxWidth));

    string cell(string s, size_t w) {
      auto n = s.count;
      if (n > w)
        return s.take(w - 1).text ~ "…";
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
string formatTime(long stdTime) {
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

/// Resolves node / request IDs to names for display.
struct NameLookup {
  string[string] nodes;
  string[string] requests;

  static NameLookup of(TransportPorts ports, TenantId tenant) {
    NameLookup l;
    foreach (n; ports.nodes.listNodes(tenant))
      l.nodes[n.id.value] = n.name;
    foreach (r; ports.requests.listRequests(tenant))
      l.requests[r.id.value] = r.name;
    return l;
  }

  string node(TransportNodeId id) const {
    if (auto n = id.value in nodes)
      return *n;
    return id.value;
  }

  string request(TransportRequestId id) const {
    if (auto n = id.value in requests)
      return *n;
    return id.value;
  }
}

Table nodeTable(const TransportNode[] nodes) {
  Table t;
  t.headers = ["Name", "Type", "Status", "Region", "Forward", "Auto-Import", "Connection", "Description", "ID"];
  foreach (n; nodes)
    t.rows ~= [
      n.name, enumName(n.nodeType), enumName(n.status), n.region, n.isForwardEnabled ? "yes" : "no",
      n.autoImport ? "yes" : "no", n.connectionStatus, n.description, n.id.value
    ];
  return t;
}

Table routeTable(const TransportRoute[] routes, const NameLookup names) {
  Table t;
  t.headers = ["Name", "Source", "Destination", "Status", "Seq.", "Description", "ID"];
  foreach (r; routes)
    t.rows ~= [
      r.name, names.node(r.sourceNodeId), names.node(r.destinationNodeId), enumName(r.status),
      r.sequence.to!string, r.description, r.id.value
    ];
  return t;
}

Table requestTable(const TransportRequest[] requests, const NameLookup names) {
  Table t;
  t.headers = ["Name", "Content", "Version", "Status", "Source", "Created", "Owner", "ID"];
  foreach (r; requests)
    t.rows ~= [
      r.name, enumName(r.contentType), r.version_, enumName(r.status), names.node(r.sourceNodeId),
      formatTime(r.createdAt), r.namedUser, r.id.value
    ];
  return t;
}

Table queueTable(const ImportQueueEntry[] entries, const NameLookup names) {
  Table t;
  t.headers = ["Pos.", "Node", "Request", "Status", "Selected", "Queued", "Completed", "Error", "ID"];
  foreach (e; entries)
    t.rows ~= [
      e.queuePosition.to!string, names.node(e.nodeId), names.request(e.requestId), enumName(e.status),
      e.isSelected ? "yes" : "", formatTime(e.queuedAt), formatTime(e.completedAt), e.errorMessage, e.id.value
    ];
  return t;
}

Table actionTable(const TransportAction[] actions, const NameLookup names) {
  Table t;
  t.headers = ["Time", "Action", "Status", "Node", "Request", "By", "Description", "ID"];
  foreach (a; actions)
    t.rows ~= [
      formatTime(a.performedAt), enumName(a.actionType), enumName(a.actionStatus), names.node(a.nodeId),
      names.request(a.requestId), a.performedBy, a.description, a.id.value
    ];
  return t;
}

/// Key/value view of the statistics.
Table statisticsTable(const TransportStatistics s) {
  Table t;
  t.headers = ["Figure", "Value"];
  t.rows ~= ["Tenant", s.tenantId.value];
  t.rows ~= ["Nodes (enabled)", "%d (%d)".format(s.nodes, s.enabledNodes)];
  t.rows ~= ["Routes (enabled)", "%d (%d)".format(s.routes, s.enabledRoutes)];
  t.rows ~= ["Transport requests", s.requests.to!string];
  t.rows ~= ["Queue entries", s.queueEntries.to!string];
  t.rows ~= ["Pending imports", s.pendingImports.to!string];
  t.rows ~= ["Running imports", s.runningImports.to!string];
  t.rows ~= ["Successful imports", s.successfulImports.to!string];
  t.rows ~= ["Failed imports", s.failedImports.to!string];
  t.rows ~= ["Actions", s.actions.to!string];
  t.rows ~= ["Last action", formatTime(s.lastActionAt)];
  foreach (k; s.requestsByStatus.keys.sort)
    t.rows ~= ["Requests " ~ k, s.requestsByStatus[k].to!string];
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
  assert(formatTime(0) == "");
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The transport landscape: nodes connected by directed routes.
module uim.platform.transport.domain.services.landscape;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Immutable snapshot of a tenant's landscape with graph queries.
struct TransportLandscape {
  TransportNode[] nodes;
  TransportRoute[] routes;

  this(TransportNode[] nodes, TransportRoute[] routes) {
    this.nodes = nodes.dup.sort!((a, b) => a.name < b.name).array;
    this.routes = routes.dup.sort!((a, b) => a.sequence == b.sequence ? a.name < b.name : a.sequence < b.sequence).array;
  }

  bool hasNode(TransportNodeId id) const {
    return nodes.any!(n => n.id == id);
  }

  TransportNode node(TransportNodeId id) const {
    foreach (n; nodes)
      if (n.id == id)
        return n;
    return TransportNode.init;
  }

  TransportNode nodeByName(string name) const {
    foreach (n; nodes)
      if (n.name == name)
        return n;
    return TransportNode.init;
  }

  /// Enabled outgoing routes of a node whose destination node is enabled.
  TransportRoute[] outgoing(TransportNodeId source) const {
    TransportRoute[] result;
    foreach (r; routes)
      if (r.sourceNodeId == source && r.isEnabled && node(r.destinationNodeId).isEnabled)
        result ~= r;
    return result;
  }

  /// Follow-on nodes of a node (targets of enabled routes).
  TransportNodeId[] destinations(TransportNodeId source) const {
    return outgoing(source).map!(r => r.destinationNodeId).array;
  }

  /// Nodes without incoming routes (where content enters the landscape).
  TransportNode[] entryNodes() const {
    TransportNode[] result;
    foreach (n; nodes)
      if (!routes.any!(r => r.destinationNodeId == n.id))
        result ~= n;
    return result;
  }

  /// True if a route source → destination already exists.
  bool hasRoute(TransportNodeId source, TransportNodeId destination) const {
    return routes.any!(r => r.connects(source, destination));
  }

  /// True if adding source → destination would close a cycle
  /// (i.e. source is already reachable from destination).
  bool wouldCreateCycle(TransportNodeId source, TransportNodeId destination) const {
    if (source == destination)
      return true;
    return reachableFrom(destination).canFind(source);
  }

  /// All nodes reachable from start via any route (regardless of status), breadth-first.
  TransportNodeId[] reachableFrom(TransportNodeId start) const {
    TransportNodeId[] order;
    bool[string] seen;
    TransportNodeId[] queue = [start];
    seen[start.value] = true;
    while (queue.length > 0) {
      auto current = queue[0];
      queue = queue[1 .. $];
      foreach (r; routes) {
        if (r.sourceNodeId != current || r.destinationNodeId.value in seen)
          continue;
        seen[r.destinationNodeId.value] = true;
        order ~= r.destinationNodeId;
        queue ~= r.destinationNodeId;
      }
    }
    return order;
  }

  /// Text rendering of the topology:  DEV → QA → PROD
  string render() const {
    string[] lines;
    bool[string] printed;

    void walk(const TransportNode n, string indent) {
      auto mark = n.isEnabled ? "" : " (disabled)";
      lines ~= indent ~ n.name ~ " [" ~ enumName(n.nodeType) ~ "]" ~ mark;
      if (n.id.value in printed)
        return;
      printed[n.id.value] = true;
      foreach (r; routes) {
        if (r.sourceNodeId != n.id)
          continue;
        auto label = r.isEnabled ? r.name : r.name ~ " (disabled)";
        lines ~= indent ~ "  └─ " ~ label ~ " →";
        walk(node(r.destinationNodeId), indent ~ "     ");
      }
    }

    foreach (n; entryNodes)
      walk(n, "");
    foreach (n; nodes) // nodes only reachable through cycles (should not exist)
      if (n.id.value !in printed)
        walk(n, "");
    return lines.join("\n") ~ (lines.length ? "\n" : "");
  }
}

///
unittest {
  mixin(ShowTest!("TransportLandscape"));

  auto t = TenantId("t");
  TransportNode node(string name) {
    auto n = TransportNode(t, TransportNodeId(name));
    n.name = name;
    return n;
  }

  TransportRoute route(string from, string to) {
    auto r = TransportRoute(t, TransportRouteId(from ~ to));
    r.name = from ~ "-" ~ to;
    r.sourceNodeId = TransportNodeId(from);
    r.destinationNodeId = TransportNodeId(to);
    return r;
  }

  auto qa = node("QA");
  auto l = TransportLandscape([node("DEV"), qa, node("PROD")], [route("DEV", "QA"), route("QA", "PROD")]);
  assert(l.destinations(TransportNodeId("DEV")) == [TransportNodeId("QA")]);
  assert(l.wouldCreateCycle(TransportNodeId("PROD"), TransportNodeId("DEV")));
  assert(!l.wouldCreateCycle(TransportNodeId("DEV"), TransportNodeId("PROD")));
  assert(l.entryNodes.length == 1 && l.entryNodes[0].name == "DEV");
  assert(l.render.canFind("DEV-QA"));

  qa.disable();
  auto l2 = TransportLandscape([node("DEV"), qa], [route("DEV", "QA")]);
  assert(l2.destinations(TransportNodeId("DEV")).length == 0);
}

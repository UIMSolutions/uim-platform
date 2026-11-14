/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.services.transport_validator;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Invariants of the transport entities. Each validate* returns "" when valid,
/// otherwise a human readable reason.
struct TransportValidator {
  static string validateNode(const TransportNode node) {
    if (node.name.strip.length == 0)
      return "node name is required";
    if (node.name.canFind!(c => c == ' ' || c == '/' || c == '\''))
      return "node name must not contain blanks, '/' or quotes";
    if (node.name.length > 64)
      return "node name must not exceed 64 characters";
    return "";
  }

  static string validateRoute(const TransportRoute route) {
    if (route.name.strip.length == 0)
      return "route name is required";
    if (route.sourceNodeId.isEmpty || route.destinationNodeId.isEmpty)
      return "source and destination node are required";
    if (route.sourceNodeId == route.destinationNodeId)
      return "source and destination node must differ";
    return "";
  }

  static string validateRequest(const TransportRequest request) {
    if (request.name.strip.length == 0)
      return "request name is required";
    return "";
  }

  static string validateQueueEntry(const ImportQueueEntry entry) {
    if (entry.nodeId.isEmpty || entry.requestId.isEmpty)
      return "nodeId and requestId are required";
    return "";
  }

  static string validateAction(const TransportAction action) {
    if (action.requestId.isEmpty && action.nodeId.isEmpty)
      return "requestId or nodeId is required";
    if (action.performedBy.length == 0)
      return "performedBy is required";
    return "";
  }

  // Boolean convenience wrappers (kept for backwards compatibility).
  static bool isValidNode(const TransportNode n) { return validateNode(n).length == 0; }
  static bool isValidRoute(const TransportRoute r) { return validateRoute(r).length == 0; }
  static bool isValidRequest(const TransportRequest r) { return validateRequest(r).length == 0; }
  static bool isValidQueueEntry(const ImportQueueEntry e) { return validateQueueEntry(e).length == 0; }
  static bool isValidAction(const TransportAction a) { return validateAction(a).length == 0; }
}

///
unittest {
  mixin(ShowTest!("TransportValidator"));

  TransportNode n;
  assert(TransportValidator.validateNode(n).length > 0);
  n.name = "QA";
  assert(TransportValidator.isValidNode(n));
  n.name = "Q A";
  assert(!TransportValidator.isValidNode(n));

  TransportRoute r;
  r.name = "r";
  r.sourceNodeId = TransportNodeId("a");
  r.destinationNodeId = TransportNodeId("a");
  assert(!TransportValidator.isValidRoute(r));
  r.destinationNodeId = TransportNodeId("b");
  assert(TransportValidator.isValidRoute(r));
}

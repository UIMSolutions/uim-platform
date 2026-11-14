/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.operations;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Export a request from its source node: it is added to the import queues of
/// all follow-on nodes (destinations of enabled routes).
struct ExportInput {
  TenantId tenantId;
  TransportRequestId requestId;
  /// Export node; defaults to the request's sourceNodeId.
  TransportNodeId nodeId;
  string performedBy;
}

/// Import the queue of a node.
struct ImportInput {
  TenantId tenantId;
  TransportNodeId nodeId;
  /// Entries to import; empty = all selected, pending entries in queue order.
  ImportQueueEntryId[] entryIds;
  string performedBy;
}

/// Forward a request from a node to its follow-on nodes.
struct ForwardInput {
  TenantId tenantId;
  TransportRequestId requestId;
  TransportNodeId fromNodeId;
  string performedBy;
}

/// Summary of an import run (also returned as UsecaseResult.data).
struct ImportRunSummary {
  TransportNodeId nodeId;
  size_t imported;
  size_t succeeded;
  size_t warnings;
  size_t failed;
  size_t forwarded;
  string[] entryIds;

  Json toJson() const {
    auto ids = Json.emptyArray;
    foreach (id; entryIds)
      ids ~= Json(id);
    return Json.emptyObject
      .set("nodeId", nodeId.value)
      .set("imported", imported)
      .set("succeeded", succeeded)
      .set("warnings", warnings)
      .set("failed", failed)
      .set("forwarded", forwarded)
      .set("entryIds", ids);
  }
}

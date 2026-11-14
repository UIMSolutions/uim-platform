/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.import_queue_entry;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// REST: /api/v1/transport/queue-entries   (GET ?nodeId=… filters by node)
///   PUT {"action": "reset" | "select" | "deselect"} or {"status": "...", "errorMessage"}
class ImportQueueEntryController : ManageHttpController {
  protected IManageImportQueueUseCase queue;

  this(IManageImportQueueUseCase queue) {
    this.queue = queue;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get(restBase ~ "/queue-entries", &handleList);
    router.get(restBase ~ "/queue-entries/*", &handleGet);
    router.post(restBase ~ "/queue-entries", &handleCreate);
    router.put(restBase ~ "/queue-entries/*", &handleUpdate);
    router.delete_(restBase ~ "/queue-entries/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;
    auto nodeId = req.query.get("nodeId", "");
    auto items = nodeId.length > 0
      ? queue.listEntriesByNode(precheck.tenantId, TransportNodeId(nodeId)) : queue.listEntries(precheck.tenantId);
    return successResponse("Import queue entries retrieved", "Retrieved", 200, listPayload(items));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto entry = queue.getEntry(precheck.tenantId, ImportQueueEntryId(precheck.id));
    if (entry.isNull)
      return errorResponse("Import queue entry not found", 404);
    return successResponse("Import queue entry retrieved", "Retrieved", 200, entry.toJson);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;
    auto data = precheck.data;
    EnqueueInput input;
    input.tenantId = precheck.tenantId;
    input.id = data.getString("id");
    input.nodeId = data.getString("nodeId");
    input.requestId = data.getString("requestId");
    input.queuePosition = pickInt(data, "queuePosition", 0);
    input.isSelected = pickBool(data, "isSelected", true);
    input.scheduledAt = fieldLong(data, "scheduledAt");
    input.createdBy = UserId(data.getString("createdBy"));
    return usecaseResponse(queue.enqueue(input), "Created", 201);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenant = precheck.tenantId;
    auto id = ImportQueueEntryId(precheck.id);
    auto data = precheck.data;
    switch (data.getString("action")) {
    case "reset":
      return usecaseResponse(queue.resetEntry(tenant, id, data.getString("performedBy")), "Reset");
    case "select":
      return usecaseResponse(queue.selectEntry(tenant, id, true), "Selected");
    case "deselect":
      return usecaseResponse(queue.selectEntry(tenant, id, false), "Deselected");
    default:
      break;
    }
    auto statusText = data.getString("status");
    if (statusText.length == 0)
      return errorResponse("'action' (reset | select | deselect) or 'status' is required", 400);
    ImportStatus status;
    if (!tryParseEnum!ImportStatus(statusText, status))
      return errorResponse("Invalid status '" ~ statusText ~ "'", 400);
    return usecaseResponse(queue.updateEntryStatus(tenant, id, status, data.getString("errorMessage")), "Updated");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;
    return usecaseResponse(queue.deleteEntry(precheck.tenantId, ImportQueueEntryId(precheck.id)), "Deleted");
  }
}

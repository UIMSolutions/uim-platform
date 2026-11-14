/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_action;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// REST: /api/v1/transport/actions — the audit trail (append-only, status updates allowed).
class TransportActionController : ManageHttpController {
  protected IManageTransportActionsUseCase actions;

  this(IManageTransportActionsUseCase actions) {
    this.actions = actions;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get(restBase ~ "/actions", &handleList);
    router.get(restBase ~ "/actions/*", &handleGet);
    router.post(restBase ~ "/actions", &handleCreate);
    router.put(restBase ~ "/actions/*", &handleUpdate);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;
    return successResponse("Transport actions retrieved", "Retrieved", 200, listPayload(actions.listActions(precheck.tenantId)));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto action = actions.getAction(precheck.tenantId, TransportActionId(precheck.id));
    if (action.isNull)
      return errorResponse("Transport action not found", 404);
    return successResponse("Transport action retrieved", "Retrieved", 200, action.toJson);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;
    auto data = precheck.data;
    RecordActionInput input;
    input.tenantId = precheck.tenantId;
    input.id = data.getString("id");
    input.actionType = data.getString("actionType");
    input.actionStatus = data.getString("actionStatus");
    input.nodeId = data.getString("nodeId");
    input.requestId = data.getString("requestId");
    input.routeId = data.getString("routeId");
    input.performedBy = data.getString("performedBy");
    input.description = data.getString("description");
    input.logDetails = data.getString("logDetails");
    input.errorMessage = data.getString("errorMessage");
    return usecaseResponse(actions.recordAction(input), "Recorded", 201);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;
    auto data = precheck.data;
    ActionStatus status;
    if (!tryParseEnum!ActionStatus(data.getString("actionStatus"), status))
      return errorResponse("A valid 'actionStatus' is required", 400);
    return usecaseResponse(actions.updateActionStatus(precheck.tenantId, TransportActionId(precheck.id), status,
        data.getString("errorMessage")), "Updated");
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_route;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// REST: /api/v1/transport/routes  (PUT {"action": "enable" | "disable"} or field updates)
class TransportRouteController : ManageHttpController {
  protected IManageTransportRoutesUseCase routes;

  this(IManageTransportRoutesUseCase routes) {
    this.routes = routes;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get(restBase ~ "/routes", &handleList);
    router.get(restBase ~ "/routes/*", &handleGet);
    router.post(restBase ~ "/routes", &handleCreate);
    router.put(restBase ~ "/routes/*", &handleUpdate);
    router.delete_(restBase ~ "/routes/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;
    return successResponse("Transport routes retrieved", "Retrieved", 200, listPayload(routes.listRoutes(precheck.tenantId)));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto route = routes.getRoute(precheck.tenantId, TransportRouteId(precheck.id));
    if (route.isNull)
      return errorResponse("Transport route not found", 404);
    return successResponse("Transport route retrieved", "Retrieved", 200, route.toJson);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;
    auto data = precheck.data;
    CreateRouteInput input;
    input.tenantId = precheck.tenantId;
    input.id = data.getString("id");
    input.name = data.getString("name");
    input.description = data.getString("description");
    input.sourceNodeId = data.getString("sourceNodeId");
    input.destinationNodeId = data.getString("destinationNodeId");
    input.status = data.getString("status");
    input.isSequential = pickBool(data, "isSequential", true);
    input.sequence = pickInt(data, "sequence", 0);
    input.createdBy = UserId(data.getString("createdBy"));
    return usecaseResponse(routes.createRoute(input), "Created", 201);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenant = precheck.tenantId;
    auto id = TransportRouteId(precheck.id);
    auto data = precheck.data;
    switch (data.getString("action")) {
    case "enable":
      return usecaseResponse(routes.enableRoute(tenant, id), "Enabled");
    case "disable":
      return usecaseResponse(routes.disableRoute(tenant, id), "Disabled");
    default:
      break;
    }
    auto current = routes.getRoute(tenant, id);
    if (current.isNull)
      return errorResponse("Transport route not found", 404);
    auto input = UpdateRouteInput.from(current);
    input.name = pick(data, "name", input.name);
    input.description = pick(data, "description", input.description);
    input.status = pick(data, "status", input.status);
    input.isSequential = pickBool(data, "isSequential", input.isSequential);
    input.sequence = pickInt(data, "sequence", input.sequence);
    input.updatedBy = UserId(data.getString("updatedBy"));
    return usecaseResponse(routes.updateRoute(input), "Updated");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;
    return usecaseResponse(routes.deleteRoute(precheck.tenantId, TransportRouteId(precheck.id)), "Deleted");
  }
}

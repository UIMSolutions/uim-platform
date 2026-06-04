/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.connection;
// import uim.platform.datasphere.application.usecases.manage.connections;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class ConnectionController : ManageHttpController {
  private ManageConnectionsUseCase usecase;

  this(ManageConnectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/connections", &handleList);
    router.get("/api/v1/datasphere/connections/*", &handleGet);
    router.post("/api/v1/datasphere/connections", &handleCreate);
    router.delete_("/api/v1/datasphere/connections/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateConnectionRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.host = data.getString("host");
    r.port = data.getInteger("port", 0);
    r.database = data.getString("database");
    r.user = data.getString("user");

    auto result = usecase.createConnection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Connection created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto connections = usecase.listConnections(tenantId, spaceId);
    auto list = Json.emptyArray;
    foreach (c; connections) {
      list ~= Json.emptyObject
        .set("id", c.id)
        .set("name", c.name)
        .set("description", c.description)
        .set("isValid", c.isValid)
        .set("statusMessage", c.statusMessage)
        .set("createdAt", c.createdAt)
        .set("updatedAt", c.updatedAt);
    }

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Connections retrieved successfully", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConnectionId(precheck.id);
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto c = usecase.getConnection(tenantId, spaceId, id);
    if (c.isNull)
      return errorResponse("Connection not found", 404);

    auto resp = Json.emptyObject
      .set("id", c.id)
      .set("name", c.name)
      .set("description", c.description)
      .set("host", c.host)
      .set("port", c.port)
      .set("database", c.database)
      .set("isValid", c.isValid)
      .set("statusMessage", c.statusMessage)
      .set("createdAt", c.createdAt)
      .set("updatedAt", c.updatedAt)
      .set("message", "Connection retrieved successfully");

    return successResponse("Connection retrieved successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConnectionId(precheck.id);
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto result = usecase.deleteConnection(tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Connection deleted successfully", 204, Json.emptyObject);
  }
}

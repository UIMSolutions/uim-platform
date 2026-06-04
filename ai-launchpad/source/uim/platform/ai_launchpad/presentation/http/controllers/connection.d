/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.connection;

// import uim.platform.ai_launchpad.application.usecases.manage.connections;
// import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ConnectionController : ManageHttpController {
  private ManageConnectionsUseCase usecase;

  this(ManageConnectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/connections", &handleCreate);
    router.get("/api/v1/connections", &handleList);
    router.get("/api/v1/connections/*", &handleGet);
    router.patch("/api/v1/connections/*", &handlePatch);
    router.delete_("/api/v1/connections/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto workspaceId = WorkspaceId(req.headers.get("X-Workspace-Id", ""));

    auto items = workspaceId.isNull
      ? usecase.listConnections(tenantId) : usecase.listConnections(tenantId, workspaceId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Connection list retrieved successfully", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateConnectionRequest r;
    r.tenantId = precheck.tenantId;
    r.connectionId = ConnectionId(data.getString("id"));
    r.workspaceId = WorkspaceId(req.headers.get("X-Workspace-Id", ""));
    r.clientSecret = data.getString("clientSecret");
    r.description = data.getString("description");
    r.defaultResourceGroupId = data.getString("defaultResourceGroupId");

    auto result = usecase.createConnection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Connection created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ConnectionId(precheck.id);

    auto connection = usecase.getConnection(tenantId, id);
    if (connection.isNull)
      return errorResponse("Connection not found", 404);

    auto responseData = connection.toJson();
    return successResponse("Connection retrieved successfully", 200, responseData);
  }

  protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConnectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid connection ID", 400);

    auto data = precheck.data;
    PatchConnectionRequest r;
    r.tenantId = precheck.tenantId;
    r.connectionId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.defaultResourceGroupId = data.getString("defaultResourceGroupId");

    auto result = usecase.patchConnection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("message", "Connection updated");

    return successResponse("Connection updated successfully", 200, resp);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJsonBody(response.data, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConnectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid connection ID", 400);

    auto result = usecase.deleteConnection(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Connection deleted successfully", 200, responseData);
  }
}

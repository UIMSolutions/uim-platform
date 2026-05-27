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

class ConnectionController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateConnectionRequest r;
      r.tenantId = tenantId;
      r.workspaceId = WorkspaceId(req.headers.get("X-Workspace-Id", ""));
      r.clientSecret = data.getString("clientSecret");
      r.description = data.getString("description");
      r.defaultResourceGroupId = data.getString("defaultResourceGroupId");

      auto result = usecase.createConnection(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Connection created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto workspaceId = WorkspaceId(req.headers.get("X-Workspace-Id", ""));

      auto connections = workspaceId.isEmpty
        ? usecase.listConnections(tenantId)
        : usecase.listConnections(tenantId, workspaceId);

      auto jarr = connections.map!(connection => connection.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", connections.length)
        .set("resources", jarr)
        .set("message", "Connections retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Connectionprecheck.id);

      auto connection = usecase.getConnection(tenantId, id);
      if (connection.isNull) {
        writeError(res, 404, "Connection not found");
        return;
      }

      res.writeJsonBody(connection.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Connectionprecheck.id);
      auto data = precheck.data;
      PatchConnectionRequest r;
      r.tenantId = tenantId;
      r.connectionId = id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.defaultResourceGroupId = data.getString("defaultResourceGroupId");

      auto result = usecase.patchConnection(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("message", "Connection updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Connectionprecheck.id);

      auto result = usecase.deleteConnection(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto response = Json.emptyObject
          .set("message", "Connection deleted");

        res.writeJsonBody(response, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}

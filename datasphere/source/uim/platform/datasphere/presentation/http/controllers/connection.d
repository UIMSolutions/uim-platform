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

class ConnectionController : PlatformController {
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

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateConnectionRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.host = j.getString("host");
      r.port = j.getInteger("port", 0);
      r.database = j.getString("database");
      r.user = j.getString("user");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Connection created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto connections = usecase.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (c; connections) {
        jarr ~= Json.emptyObject
          .set("id", c.id)
          .set("name", c.name)
          .set("description", c.description)
          .set("isValid", c.isValid)
          .set("statusMessage", c.statusMessage)
          .set("createdAt", c.createdAt)
          .set("updatedAt", c.updatedAt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(connections.length))
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ConnectionId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto c = usecase.getById(id, spaceId);
      if (c.id.isEmpty) {
        writeError(res, 404, "Connection not found");
        return;
      }

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

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ConnectionId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = usecase.deleteConnection(id, spaceId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

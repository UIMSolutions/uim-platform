/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.connection;

import uim.platform.datasphere.application.usecases.manage.connections;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class ConnectionController : PlatformController {
  private ManageConnectionsUseCase uc;

  this(ManageConnectionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/connections", &handleList);
    router.get("/api/v1/datasphere/connections/*", &handleGet);
    router.post("/api/v1/datasphere/connections", &handleCreate);
    router.delete_("/api/v1/datasphere/connections/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConnectionRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.host = j.getString("host");
      r.port = j.getInteger("port", 0);
      r.database = j.getString("database");
      r.user = j.getString("user");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Connection created"));

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = req.headers.get("X-Space-Id", "");
      auto connections = uc.list(spaceId);

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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto c = uc.getById(id, spaceId);
      if (c.id.isEmpty) {
        writeError(res, 404, "Connection not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", Json(c.id))
        .set("name", Json(c.name))
        .set("description", Json(c.description))
        .set("host", Json(c.host))
        .set("port", Json(c.port))
        .set("database", Json(c.database))
        .set("isValid", Json(c.isValid))
        .set("statusMessage", Json(c.statusMessage))
        .set("createdAt", Json(c.createdAt))
        .set("updatedAt", Json(c.updatedAt))
        .set("message", "Connection retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto result = uc.remove(id, spaceId);
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

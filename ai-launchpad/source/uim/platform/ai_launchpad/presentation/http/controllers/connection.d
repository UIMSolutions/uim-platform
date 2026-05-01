/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.connection;

import uim.platform.ai_launchpad.application.usecases.manage.connections;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class ConnectionController : PlatformController {
  private ManageConnectionsUseCase uc;

  this(ManageConnectionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/connections", &handleCreate);
    router.get("/api/v1/connections", &handleList);
    router.get("/api/v1/connections/*", &handleGet);
    router.patch("/api/v1/connections/*", &handlePatch);
    router.delete_("/api/v1/connections/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConnectionRequest r;
      r.workspaceId = j.getString("workspaceId");
      r.name = j.getString("name");
      r.type = j.getString("type");
      r.url = j.getString("url");
      r.authUrl = j.getString("authUrl");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.description = j.getString("description");
      r.defaultResourceGroupId = j.getString("defaultResourceGroupId");

      auto result = uc.create(r);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto workspaceId = req.headers.get("X-Workspace-Id", "");

      typeof(uc.listAll()) connections;
      if (workspaceId.length > 0)
        connections = uc.listByWorkspace(workspaceId);
      else
        connections = uc.listAll();

      auto jarr = connections.map!(connection => connection.toJson).array;

      auto resp = Json.emptyObject
      .set("count", connections.length)
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

      auto connection = uc.getById(id);
      if (connection.isNull) {
        writeError(res, 404, "Connection not found");
        return;
      }

      res.writeJsonBody(connection.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchConnectionRequest r;
      r.connectionId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.defaultResourceGroupId = j.getString("defaultResourceGroupId");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("message", "Connection updated");
        
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);

      auto result = uc.remove(id);
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

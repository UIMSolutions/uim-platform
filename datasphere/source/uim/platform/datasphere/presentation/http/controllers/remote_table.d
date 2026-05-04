/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.remote_table;

// import uim.platform.datasphere.application.usecases.manage.remote_tables;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class RemoteTableController : PlatformController {
  private ManageRemoteTablesUseCase uc;

  this(ManageRemoteTablesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/remoteTables", &handleList);
    router.get("/api/v1/datasphere/remoteTables/*", &handleGet);
    router.post("/api/v1/datasphere/remoteTables", &handleCreate);
    router.delete_("/api/v1/datasphere/remoteTables/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateRemoteTableRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.connectionId = j.getString("connectionId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.remoteSchema = j.getString("remoteSchema");
      r.remoteObjectName = j.getString("remoteObjectName");
      r.replicationMode = j.getString("replicationMode");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Remote table created");

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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto tables = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (rt; tables) {
        jarr ~= Json.emptyObject
          .set("id", rt.id)
          .set("name", rt.name)
          .set("description", rt.description)
          .set("connectionId", rt.connectionId)
          .set("remoteSchema", rt.remoteSchema)
          .set("remoteObjectName", rt.remoteObjectName)
          .set("rowCount", rt.rowCount)
          .set("lastReplicatedAt", rt.lastReplicatedAt)
          .set("createdAt", rt.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(tables.length))
        .set("resources", jarr)
        .set("message", "Remote tables retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = RemoteTableId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto rt = uc.getById(spaceId, id);
      if (rt.isNull) {
        writeError(res, 404, "Remote table not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", rt.id)
        .set("name", rt.name)
        .set("description", rt.description)
        .set("connectionId", rt.connectionId)
        .set("remoteSchema", rt.remoteSchema)
        .set("remoteObjectName", rt.remoteObjectName)
        .set("rowCount", rt.rowCount)
        .set("lastReplicatedAt", rt.lastReplicatedAt)
        .set("createdAt", rt.createdAt)
        .set("updatedAt", rt.updatedAt)
        .set("message", "Remote table retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = RemoteTableId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = uc.remove(spaceId, id);
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

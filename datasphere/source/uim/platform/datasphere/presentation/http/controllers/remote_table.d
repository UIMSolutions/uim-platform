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

class RemoteTableController : ManageController {
  private ManageRemoteTablesUseCase usecase;

  this(ManageRemoteTablesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/remoteTables", &handleList);
    router.get("/api/v1/datasphere/remoteTables/*", &handleGet);
    router.post("/api/v1/datasphere/remoteTables", &handleCreate);
    router.delete_("/api/v1/datasphere/remoteTables/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      CreateRemoteTableRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.connectionId = ConnectionId(data.getString("connectionId"));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.remoteSchema = data.getString("remoteSchema");
      r.remoteObjectName = data.getString("remoteObjectName");
      r.replicationMode = data.getString("replicationMode");

      auto result = usecase.createRemoteTable(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Remote table created");

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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto tables = usecase.listRemoteTables(tenantId, spaceId);
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = RemoteTableprecheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto rt = usecase.getRemoteTableById(tenantId, spaceId, id);
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

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = RemoteTableprecheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = usecase.deleteRemoteTable(tenantId, spaceId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

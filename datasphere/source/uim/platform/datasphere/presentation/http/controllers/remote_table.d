/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.remote_table;

import uim.platform.datasphere.application.usecases.manage.remote_tables;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class RemoteTableController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.connectionId = jsonStr(j, "connectionId");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.remoteSchema = jsonStr(j, "remoteSchema");
      r.remoteObjectName = jsonStr(j, "remoteObjectName");
      r.replicationMode = jsonStr(j, "replicationMode");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Remote table created");
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = req.headers.get("X-Space-Id", "");
      auto tables = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (ref rt; tables) {
        auto rj = Json.emptyObject;
        rj["id"] = Json(rt.id);
        rj["name"] = Json(rt.name);
        rj["description"] = Json(rt.description);
        rj["connectionId"] = Json(rt.connectionId);
        rj["remoteSchema"] = Json(rt.remoteSchema);
        rj["remoteObjectName"] = Json(rt.remoteObjectName);
        rj["rowCount"] = Json(rt.rowCount);
        rj["lastReplicatedAt"] = Json(rt.lastReplicatedAt);
        rj["createdAt"] = Json(rt.createdAt);
        jarr ~= rj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) tables.length);
      resp["resources"] = jarr;
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

      auto rt = uc.get_(id, spaceId);
      if (rt.id.length == 0) {
        writeError(res, 404, "Remote table not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(rt.id);
      resp["name"] = Json(rt.name);
      resp["description"] = Json(rt.description);
      resp["connectionId"] = Json(rt.connectionId);
      resp["remoteSchema"] = Json(rt.remoteSchema);
      resp["remoteObjectName"] = Json(rt.remoteObjectName);
      resp["rowCount"] = Json(rt.rowCount);
      resp["lastReplicatedAt"] = Json(rt.lastReplicatedAt);
      resp["createdAt"] = Json(rt.createdAt);
      resp["modifiedAt"] = Json(rt.modifiedAt);
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
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.stream;

import uim.platform.logging.application.usecases.manage.log_streams;
import uim.platform.logging.application.dto;
import uim.platform.logging.domain.entities.log_stream;
import uim.platform.logging.domain.types;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class StreamController : PlatformController {
  private ManageLogStreamsUseCase uc;

  this(ManageLogStreamsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/streams", &handleCreate);
    router.get("/api/v1/streams", &handleList);
    router.get("/api/v1/streams/*", &handleGet);
    router.put("/api/v1/streams/*", &handleUpdate);
    router.delete_("/api/v1/streams/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateLogStreamRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.sourceType = j.getString("sourceType");
      r.retentionPolicyId = j.getString("retentionPolicyId");
      r.createdBy = j.getString("createdBy");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      TenantId tenantId = req.getTenantId;
      auto streams = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (s; streams) {
        auto sj = Json.emptyObject;
        sj["id"] = Json(s.id);
        sj["name"] = Json(s.name);
        sj["description"] = Json(s.description);
        sj["isActive"] = Json(s.isActive);
        jarr ~= sj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) streams.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto s = uc.get_(id);

      if (s.id.isEmpty) {
        writeError(res, 404, "Log stream not found");
        return;
      }

      auto sj = Json.emptyObject;
      sj["id"] = Json(s.id);
      sj["tenantId"] = Json(s.tenantId);
      sj["name"] = Json(s.name);
      sj["description"] = Json(s.description);
      sj["isActive"] = Json(s.isActive);
      sj["retentionPolicyId"] = Json(s.retentionPolicyId);
      res.writeJsonBody(sj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateLogStreamRequest r;
      r.description = j.getString("description");
      r.retentionPolicyId = j.getString("retentionPolicyId");
      r.isActive = jsonBool(j, "isActive", true);

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      uc.remove(id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.data_flow;

import uim.platform.datasphere.application.usecases.manage.data_flows;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class DataFlowController : SAPController {
  private ManageDataFlowsUseCase uc;

  this(ManageDataFlowsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/datasphere/dataFlows", &handleList);
    router.get("/api/v1/datasphere/dataFlows/*", &handleGet);
    router.post("/api/v1/datasphere/dataFlows", &handleCreate);
    router.delete_("/api/v1/datasphere/dataFlows/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataFlowRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.scheduleExpression = jsonStr(j, "scheduleExpression");
      r.scheduleFrequency = jsonStr(j, "scheduleFrequency");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Data flow created");
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
      auto flows = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (ref df; flows) {
        auto fj = Json.emptyObject;
        fj["id"] = Json(df.id);
        fj["name"] = Json(df.name);
        fj["description"] = Json(df.description);
        fj["lastRunAt"] = Json(df.lastRunAt);
        fj["lastRunDurationMs"] = Json(df.lastRunDurationMs);
        fj["createdAt"] = Json(df.createdAt);
        jarr ~= fj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) flows.length);
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

      auto df = uc.get_(id, spaceId);
      if (df.id.length == 0) {
        writeError(res, 404, "Data flow not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(df.id);
      resp["name"] = Json(df.name);
      resp["description"] = Json(df.description);
      resp["scheduleExpression"] = Json(df.scheduleExpression);
      resp["lastRunAt"] = Json(df.lastRunAt);
      resp["lastRunDurationMs"] = Json(df.lastRunDurationMs);
      resp["lastRunMessage"] = Json(df.lastRunMessage);
      resp["createdAt"] = Json(df.createdAt);
      resp["modifiedAt"] = Json(df.modifiedAt);
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

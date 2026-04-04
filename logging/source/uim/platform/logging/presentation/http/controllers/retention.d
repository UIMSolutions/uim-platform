/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.retention;

import uim.platform.logging.application.usecases.manage.retention_policies;
import uim.platform.logging.application.dto;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class RetentionController : SAPController {
  private ManageRetentionPoliciesUseCase uc;

  this(ManageRetentionPoliciesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/retention", &handleCreate);
    router.get("/api/v1/retention", &handleList);
    router.get("/api/v1/retention/*", &handleGet);
    router.put("/api/v1/retention/*", &handleUpdate);
    router.delete_("/api/v1/retention/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateRetentionPolicyRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.dataType = jsonStr(j, "dataType");
      r.retentionDays = jsonInt(j, "retentionDays");
      r.maxSizeGB = jsonDouble(j, "maxSizeGB");
      r.isDefault = jsonBool(j, "isDefault");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto policies = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref p; policies) {
        auto pj = Json.emptyObject;
        pj["id"] = Json(p.id);
        pj["name"] = Json(p.name);
        pj["retentionDays"] = Json(p.retentionDays);
        pj["maxSizeGB"] = Json(p.maxSizeGB);
        pj["isDefault"] = Json(p.isDefault);
        pj["isActive"] = Json(p.isActive);
        jarr ~= pj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) policies.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto p = uc.get_(id);
      if (p.id.length == 0) {
        writeError(res, 404, "Retention policy not found");
        return;
      }

      auto pj = Json.emptyObject;
      pj["id"] = Json(p.id);
      pj["name"] = Json(p.name);
      pj["description"] = Json(p.description);
      pj["retentionDays"] = Json(p.retentionDays);
      pj["maxSizeGB"] = Json(p.maxSizeGB);
      pj["isDefault"] = Json(p.isDefault);
      pj["isActive"] = Json(p.isActive);
      res.writeJsonBody(pj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateRetentionPolicyRequest r;
      r.description = jsonStr(j, "description");
      r.retentionDays = jsonInt(j, "retentionDays");
      r.maxSizeGB = jsonDouble(j, "maxSizeGB");
      r.isDefault = jsonBool(j, "isDefault");
      r.isActive = jsonBool(j, "isActive", true);

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
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

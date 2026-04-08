/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.data_access_control;

import uim.platform.datasphere.application.usecases.manage.data_access_controls;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class DataAccessControlController : SAPController {
  private ManageDataAccessControlsUseCase uc;

  this(ManageDataAccessControlsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/datasphere/dataAccessControls", &handleList);
    router.get("/api/v1/datasphere/dataAccessControls/*", &handleGet);
    router.post("/api/v1/datasphere/dataAccessControls", &handleCreate);
    router.delete_("/api/v1/datasphere/dataAccessControls/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataAccessControlRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.criteriaType = j.getString("criteriaType");
      r.targetViewIds = jsonStrArray(j, "targetViewIds");
      r.assignedUserIds = jsonStrArray(j, "assignedUserIds");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Data access control created");
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
      auto controls = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (ref dac; controls) {
        auto dj = Json.emptyObject;
        dj["id"] = Json(dac.id);
        dj["name"] = Json(dac.name);
        dj["description"] = Json(dac.description);
        dj["isEnabled"] = Json(dac.isEnabled);
        dj["createdAt"] = Json(dac.createdAt);
        jarr ~= dj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) controls.length);
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

      auto dac = uc.get_(id, spaceId);
      if (dac.id.isEmpty) {
        writeError(res, 404, "Data access control not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(dac.id);
      resp["name"] = Json(dac.name);
      resp["description"] = Json(dac.description);
      resp["isEnabled"] = Json(dac.isEnabled);
      resp["targetViewIds"] = stringsToJsonArray(dac.targetViewIds);
      resp["assignedUserIds"] = stringsToJsonArray(dac.assignedUserIds);
      resp["createdAt"] = Json(dac.createdAt);
      resp["modifiedAt"] = Json(dac.modifiedAt);
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

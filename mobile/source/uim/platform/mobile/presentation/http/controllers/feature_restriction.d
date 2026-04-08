/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.feature_restriction;

import uim.platform.mobile.application.usecases.manage.feature_restrictions;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class FeatureRestrictionController : SAPController {
  private ManageFeatureRestrictionsUseCase uc;

  this(ManageFeatureRestrictionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/features", &handleCreate);
    router.get("/api/v1/features", &handleList);
    router.get("/api/v1/features/*", &handleGet);
    router.put("/api/v1/features/*", &handleUpdate);
    router.delete_("/api/v1/features/*", &handleDelete);
    router.post("/api/v1/features/evaluate", &handleEvaluate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateFeatureRestrictionRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.featureKey = j.getString("featureKey");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.enabled = jsonBool(j, "enabled");
      r.percentage = jsonInt(j, "percentage");
      r.whitelist = jsonStrArray(j, "whitelist");
      r.metadata = j.getString("metadata");
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
      auto tenantId = req.getTenantId;
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(item.id);
        obj["appId"] = Json(item.appId);
        obj["featureKey"] = Json(item.featureKey);
        obj["type"] = Json(item.type);
        obj["enabled"] = Json(item.enabled);
        items ~= obj;
      }
      resp["items"] = items;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.get(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.data.id);
        resp["tenantId"] = Json(result.data.tenantId);
        resp["appId"] = Json(result.data.appId);
        resp["featureKey"] = Json(result.data.featureKey);
        resp["description"] = Json(result.data.description);
        resp["type"] = Json(result.data.type);
        resp["enabled"] = Json(result.data.enabled);
        resp["percentage"] = Json(result.data.percentage);
        resp["whitelist"] = toJsonArray(result.data.whitelist);
        resp["metadata"] = Json(result.data.metadata);
        resp["createdBy"] = Json(result.data.createdBy);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateFeatureRestrictionRequest r;
      r.id = id;
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.enabled = jsonBool(j, "enabled");
      r.percentage = jsonInt(j, "percentage");
      r.whitelist = jsonStrArray(j, "whitelist");
      r.metadata = j.getString("metadata");
      r.modifiedBy = j.getString("modifiedBy");
      auto result = uc.update(r);
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
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeBody("", 204);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleEvaluate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto featureId = j.getString("featureId");
      auto userId = j.getString("userId");
      auto deviceId = j.getString("deviceId");
      auto result = uc.evaluate(featureId, userId, deviceId);
      auto resp = Json.emptyObject;
      resp["enabled"] = Json(result.enabled);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

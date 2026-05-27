/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.feature_restriction;
// import uim.platform.mobile.application.usecases.manage.feature_restrictions;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class FeatureRestrictionController : ManageController {
  private ManageFeatureRestrictionsUseCase usecase;

  this(ManageFeatureRestrictionsUseCase usecase) {
    this.usecase = usecase;
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      CreateFeatureRestrictionRequest r;
      r.tenantId = tenantId;
      r.appId = data.getString("appId");
      r.featureKey = data.getString("featureKey");
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.enabled = j.getBoolean("enabled");
      r.percentage = j.getInteger("percentage");
      r.whitelist = getStrings(j, "whitelist");
      r.metadata = data.getString("metadata");
      r.createdBy = UserId(data.getString("createdBy"));
      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

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
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("featureKey", item.featureKey)
          .set("type", item.type)
          .set("enabled", item.enabled);
      }

      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", Json(results.length))
        .set("message", "Feature restrictions retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.get(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", Json(result.data.id))
          .set("tenantId", Json(result.data.tenantId))
          .set("appId", Json(result.data.appId))
          .set("featureKey", Json(result.data.featureKey))
          .set("description", Json(result.data.description))
          .set("type", Json(result.data.type))
          .set("enabled", Json(result.data.enabled))
          .set("percentage", Json(result.data.percentage))
          .set("whitelist", toJsonArray(result.data.whitelist))
          .set("metadata", Json(result.data.metadata))
          .set("createdBy", Json(result.data.createdBy))
          .set("message", "Feature restriction retrieved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto j = req.json;
      UpdateFeatureRestrictionRequest r;
      r.id = id;
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.enabled = j.getBoolean("enabled");
      r.percentage = j.getInteger("percentage");
      r.whitelist = getStrings(j, "whitelist");
      r.metadata = data.getString("metadata");
      r.updatedBy = UserId(data.getString("updatedBy"));
      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Feature restriction updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = FeatureRestrictionprecheck.id);
      auto result = usecase.deleteFeatureRestriction(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeBody("", 204);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleEvaluate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      auto featureId = data.getString("featureId");
      auto userId = data.getString("userId");
      auto deviceId = data.getString("deviceId");
      auto result = usecase.evaluate(featureId, userId, deviceId);
      auto resp = Json.emptyObject
        .set("enabled", result.enabled);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

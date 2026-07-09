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

// mixin(Showmodule!());

@safe:

class FeatureRestrictionController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateFeatureRestrictionRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.featureKey = data.getString("featureKey");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.enabled = data.getBoolean("enabled");
    r.percentage = data.getInteger("percentage");
    r.whitelist = data.getStrings("whitelist");
    r.metadata = data.getString("metadata");
    r.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.createFeatureRestriction(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Feature restriction created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

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
      .set("totalCount", Json(results.length));

    return successResponse("Feature restrictions retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FeatureRestrictionId(precheck.id);

    auto result = usecase.get(tenantId, id);
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
      .set("createdBy", Json(result.data.createdBy));

    return successResponse("Feature restriction retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto data = precheck.data;
    UpdateFeatureRestrictionRequest r;
    r.id = id;
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.enabled = data.getBoolean("enabled");
    r.percentage = data.getInteger("percentage");
    r.whitelist = data.getStrings("whitelist");
    r.metadata = data.getString("metadata");
    r.updatedBy = UserId(data.getString("updatedBy"));
    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Feature restriction updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FeatureRestrictionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid feature restriction ID", 400);

    auto result = usecase.deleteFeatureRestriction(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    
    return successResponse("Feature restriction deleted successfully", "Deleted", 200);
}

protected void handleEvaluate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
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

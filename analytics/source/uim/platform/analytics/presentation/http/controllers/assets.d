module uim.platform.analytics.presentation.http.controllers.assets;

import std.array : array;
import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.service;
import uim.platform.analytics.application.dto;
import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.http.json_utils : extractAssetId;
import uim.platform.service.helpers.read : readStringArray;
import uim.platform.service.presentation.http.controllers.manage : ManageHttpController;
import uim.platform.analytics;

// mixin(ShowModule!());

@safe:
class AnalyticsAssetsController : ManageHttpController {
  private ManageAssetsUseCase useCase;

  this(ManageAssetsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/analytics/assets", &handleList);
    router.post("/api/v1/analytics/assets", &handleCreate);
    router.get("/api/v1/analytics/assets/*", &handleGet);
    router.put("/api/v1/analytics/assets/*", &handleUpdate);
    router.delete_("/api/v1/analytics/assets/*", &handleDelete);
    router.post("/api/v1/analytics/assets/*/publish", &handlePublish);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId.value;
    auto items = (() @trusted => useCase.listAssets(tenantId))();

    auto jsonItems = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", jsonItems.length)
      .set("resources", jsonItems);
    return successResponse("Asset list retrieved successfully", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId.value;

    auto data = precheck.data;
    CreateAssetRequest dto;
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.kind = data.getString("kind");
    dto.sourceSystem = data.getString("sourceSystem");
    dto.dimensions = readStringArray(data, "dimensions");
    dto.measures = readStringArray(data, "measures");

    auto result = (() @trusted => useCase.createAsset(dto))();
    if (!result.success)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Asset created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId.value;
    auto id = precheck.id;
    if (id.length == 0)
      return errorResponse("Invalid asset ID", 400);

    auto item = (() @trusted => useCase.getAsset(tenantId, id))();

    if (item.isNull)
      return errorResponse("Asset not found", 404);

    auto responseData = item.toJson();
    return successResponse("Asset retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId.value;
    auto id = precheck.id;
    if (id.length == 0)
      return errorResponse("Invalid asset ID", 400);

    auto data = precheck.data;

    UpdateAssetRequest dto;
    dto.tenantId = tenantId;
    dto.id = id;
    dto.name = data.getString("name");
    dto.kind = data.getString("kind");
    dto.sourceSystem = data.getString("sourceSystem");
    dto.dimensions = readStringArray(data, "dimensions");
    dto.measures = readStringArray(data, "measures");

    auto result = (() @trusted => useCase.updateAsset(dto))();
    if (!result.success)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Asset updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId.value;
    auto id = precheck.id;
    if (id.length == 0)
      return errorResponse("Invalid asset ID", 400);

    auto result = (() @trusted => useCase.deleteAsset(tenantId, id))();
    if (!result.success)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Asset deleted successfully", 200, responseData);
  }

  private void handlePublish(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError) {
      res.writeJsonBody(precheck, precheck.code);
      return;
    }

    auto tenantId = precheck.tenantId.value;
    auto id = extractAssetId(req);
    if (id.length == 0) {
      res.writeJsonBody(errorResponse("Invalid asset ID", 400), 400);
      return;
    }

    auto result = (() @trusted => useCase.publishAsset(tenantId, id))();

    if (!result.success) {
      res.writeJsonBody(errorResponse(result.message, 400), 400);
      return;
    }

    auto payload = Json.emptyObject;
    payload["id"] = Json(result.id);
    payload["status"] = Json("published");
    res.writeJsonBody(payload, 200);
  }
}

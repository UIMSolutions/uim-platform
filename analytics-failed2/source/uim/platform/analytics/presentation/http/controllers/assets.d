module uim.platform.analytics.presentation.http.controllers.assets;

import std.array : array;
import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.analytics.application.dto;
import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.http.json_utils;

class AnalyticsAssetsController : ManageHttpController {
  private ManageAssetsUseCase useCase;

  this(ManageAssetsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
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

    auto tenantId = precheck.tenantId;

    auto items = useCase.listAssets(tenantId);

    auto list = Json.emptyArray;
    foreach (item; items)
      list ~= item.toJson();

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Asset list retrieved successfully", "Retrieved", 200, responseData);

  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAssetRequest dto;
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.kind = data.getString("kind");
    dto.sourceSystem = data.getString("sourceSystem");
    dto.dimensions = readStringArray(data, "dimensions");
    dto.measures = readStringArray(data, "measures");

    auto result = useCase.createAsset(dto);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Asset created successfully", "Created", 201, responseData);
  }

  private void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = tenantFromQuery(req);
    auto id = extractAssetId(req);

    auto item = useCase.getAsset(tenantId, id);
    if (item.isNull) {
      writeError(res, 404, "Asset not found");
      return;
    }

    res.writeJsonBody(item.toJson(), 200);
  }

  private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto body = req.json;
    UpdateAssetRequest dto;
    dto.tenantId = tenantFromQuery(req);
    dto.id = extractAssetId(req);
    dto.name = body["name"].get!string;
    dto.kind = body["kind"].get!string;
    dto.sourceSystem = body["sourceSystem"].get!string;
    dto.dimensions = readStringArray(body, "dimensions");
    dto.measures = readStringArray(body, "measures");

    auto result = useCase.updateAsset(dto);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Asset updated successfully", "Updated", 200, responseData);
  }

  private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = tenantFromQuery(req);
    auto id = extractAssetId(req);
    auto result = useCase.deleteAsset(tenantId, id);

    if (result.hasError) {
      writeError(res, 404, result.message);
      return;
    }

    auto payload = Json.emptyObject;
    payload["id"] = Json(result.id);
    res.writeJsonBody(payload, 200);
  }

  private void handlePublish(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = tenantFromQuery(req);
    auto id = extractAssetId(req);
    auto result = useCase.publishAsset(tenantId, id);

    if (result.hasError) {
      writeError(res, 404, result.message);
      return;
    }

    auto payload = Json.emptyObject;
    payload["id"] = Json(result.id);
    payload["status"] = Json("published");
    res.writeJsonBody(payload, 200);
  }
}

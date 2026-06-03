module uim.platform.analytics.presentation.http.controllers.assets;

import std.array : array;
import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.analytics.application.dto;
import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.http.json_utils;

class AnalyticsAssetsController {
  private ManageAssetsUseCase useCase;

  this(ManageAssetsUseCase useCase) {
    this.useCase = useCase;
  }

  void registerRoutes(URLRouter router) {
    router.get("/api/v1/analytics/assets", &handleList);
    router.post("/api/v1/analytics/assets", &handleCreate);
    router.get("/api/v1/analytics/assets/*", &handleGet);
    router.put("/api/v1/analytics/assets/*", &handleUpdate);
    router.delete_("/api/v1/analytics/assets/*", &handleDelete);
    router.post("/api/v1/analytics/assets/*/publish", &handlePublish);
  }

  private void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = tenantFromQuery(req);
    auto items = useCase.listAssets(tenantId);

    auto jsonItems = Json.emptyArray;
    foreach (item; items) jsonItems ~= item.toJson();

    auto payload = Json.emptyObject;
    payload["count"] = Json(items.length);
    payload["resources"] = jsonItems;
    res.writeJsonBody(payload, 200);
  }

  private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto body = req.json;
    CreateAssetRequest dto;
    dto.tenantId = tenantFromQuery(req);
    dto.name = body["name"].get!string;
    dto.kind = body["kind"].get!string;
    dto.sourceSystem = body["sourceSystem"].get!string;
    dto.dimensions = readStringArray(body, "dimensions");
    dto.measures = readStringArray(body, "measures");

    auto result = useCase.createAsset(dto);
    if (result.hasError) {
      writeError(res, 400, result.message);
      return;
    }

    auto payload = Json.emptyObject;
    payload["id"] = Json(result.id);
    res.writeJsonBody(payload, 201);
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
    if (result.hasError) {
      writeError(res, 400, result.message);
      return;
    }

    auto payload = Json.emptyObject;
    payload["id"] = Json(result.id);
    res.writeJsonBody(payload, 200);
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

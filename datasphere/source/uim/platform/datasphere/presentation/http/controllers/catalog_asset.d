/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.catalog_asset;
// import uim.platform.datasphere.application.usecases.manage.catalog_assets;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class CatalogAssetController : ManageController {
  private ManageCatalogAssetsUseCase assets;

  this(ManageCatalogAssetsUseCase assets) {
    this.assets = assets;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/catalog", &handleList);
    router.get("/api/v1/datasphere/catalog/search", &handleSearch);
    router.get("/api/v1/datasphere/catalog/*", &handleGet);
    router.post("/api/v1/datasphere/catalog", &handleCreate);
    router.delete_("/api/v1/datasphere/catalog/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    CreateCatalogAssetRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.businessName = data.getString("businessName");
    r.assetType = data.getString("assetType");
    r.sourceObjectId = data.getString("sourceObjectId");
    r.owner = data.getString("owner");
    r.glossaryTerms = data.getStrings("glossaryTerms");

    auto result = assets.createCatalogAsset(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Catalog asset created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto assets = assets.listCatalogAssets(tenantId, spaceId);

    auto list = Json.emptyArray;
    foreach (ca; assets) {
      list ~= Json.emptyObject
        .set("id", ca.id)
        .set("name", ca.name)
        .set("description", ca.description)
        .set("businessName", ca.businessName)
        .set("owner", ca.owner)
        .set("accessCount", ca.accessCount)
        .set("createdAt", ca.createdAt);
    }

    auto list = list.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Catalog assets retrieved successfully", 0, responseData);
  }

  protected Json searchHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto query = req.params.get("q", "");

    auto assets = assets.searchCatalogAssets(tenantId, spaceId, query);

    auto list = Json.emptyArray;
    foreach (ca; assets) {
      list ~= Json.emptyObject
        .set("id", ca.id)
        .set("name", ca.name)
        .set("description", ca.description)
        .set("businessName", ca.businessName)
        .set("owner", ca.owner);
    }

    auto resp = Json.emptyObject
      .set("count", assets.length)
      .set("resources", list);
    return successResponse("Catalog assets retrieved successfully", 0, resp);
  }

  protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = searchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CatalogAssetId(precheck.id);
    if (id.isEmpty)
      return errorResponse("Invalid catalog asset ID", 400);

    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto ca = assets.getCatalogAsset(tenantId, spaceId, id);
    if (ca.isNull)
      return errorResponse("Catalog asset not found", 404);

    auto resp = Json.emptyObject
      .set("id", ca.id)
      .set("name", ca.name)
      .set("description", ca.description)
      .set("businessName", ca.businessName)
      .set("sourceObjectId", ca.sourceObjectId)
      .set("owner", ca.owner)
      .set("glossaryTerms", ca.glossaryTerms.map!(term => Json(term))
          .array.toJson)
      .set("accessCount", ca.accessCount)
      .set("createdAt", ca.createdAt)
      .set("updatedAt", ca.updatedAt)
      .set("message", "Catalog asset retrieved successfully");

    return successResponse("Catalog asset retrieved successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CatalogAssetId(precheck.id);
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto result = assets.deleteCatalogAsset(tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Catalog asset deleted successfully", 200, responseData);
  }
}

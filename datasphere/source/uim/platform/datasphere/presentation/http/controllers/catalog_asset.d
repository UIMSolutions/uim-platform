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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
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
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Catalog asset created successfully");

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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto assets = assets.listCatalogAssets(tenantId, spaceId);

      auto jarr = Json.emptyArray;
      foreach (ca; assets) {
        jarr ~= Json.emptyObject
          .set("id", ca.id)
          .set("name", ca.name)
          .set("description", ca.description)
          .set("businessName", ca.businessName)
          .set("owner", ca.owner)
          .set("accessCount", ca.accessCount)
          .set("createdAt", ca.createdAt);
      }

      auto resp = Json.emptyObject
            .set("count", Json(assets.length))
            .set("resources", jarr)
            .set("message", "Catalog assets retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto query = req.params.get("q", "");

      auto assets = assets.searchCatalogAssets(tenantId, spaceId, query);

      auto jarr = Json.emptyArray;
      foreach (ca; assets) {
        jarr ~= Json.emptyObject
        .set("id", ca.id)
        .set("name", ca.name)
        .set("description", ca.description)
        .set("businessName", ca.businessName)
        .set("owner", ca.owner);
      }

      auto resp = Json.emptyObject
            .set("count", assets.length)
            .set("resources", jarr)
            .set("message", "Catalog assets retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = CatalogAssetprecheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto ca = assets.getCatalogAsset(tenantId, spaceId, id);
      if (ca.isNull) {
        writeError(res, 404, "Catalog asset not found");
        return;
      }

      auto resp = Json.emptyObject
            .set("id", ca.id)
            .set("name", ca.name)
            .set("description", ca.description)
            .set("businessName", ca.businessName)
            .set("sourceObjectId", ca.sourceObjectId)
            .set("owner", ca.owner)
            .set("glossaryTerms", ca.glossaryTerms.map!(term => Json(term)).array.toJson)
            .set("accessCount", ca.accessCount)
            .set("createdAt", ca.createdAt)
            .set("updatedAt", ca.updatedAt)
            .set("message", "Catalog asset retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = CatalogAssetprecheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = assets.deleteCatalogAsset(tenantId, spaceId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

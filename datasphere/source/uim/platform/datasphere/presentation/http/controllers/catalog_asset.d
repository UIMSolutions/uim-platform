/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.catalog_asset;

import uim.platform.datasphere.application.usecases.manage.catalog_assets;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class CatalogAssetController : PlatformController {
  private ManageCatalogAssetsUseCase uc;

  this(ManageCatalogAssetsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/catalog", &handleList);
    router.get("/api/v1/datasphere/catalog/search", &handleSearch);
    router.get("/api/v1/datasphere/catalog/*", &handleGet);
    router.post("/api/v1/datasphere/catalog", &handleCreate);
    router.delete_("/api/v1/datasphere/catalog/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateCatalogAssetRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.businessName = j.getString("businessName");
      r.assetType = j.getString("assetType");
      r.sourceObjectId = j.getString("sourceObjectId");
      r.owner = j.getString("owner");
      r.glossaryTerms = getStringArray(j, "glossaryTerms");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Catalog asset created");
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
      auto assets = uc.list(spaceId);

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

      auto resp = Json.emptyObject;
      resp["count"] = Json(assets.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto spaceId = req.headers.get("X-Space-Id", "");
      auto query = req.params.get("q", "");

      auto assets = uc.search(query, spaceId);

      auto jarr = Json.emptyArray;
      foreach (ca; assets) {
        jarr ~= Json.emptyObject
        .set("id", ca.id)
        .set("name", ca.name)
        .set("description", ca.description)
        .set("businessName", ca.businessName)
        .set("owner", ca.owner);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(assets.length);
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

      auto ca = uc.getById(id, spaceId);
      if (ca.id.isEmpty) {
        writeError(res, 404, "Catalog asset not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(ca.id);
      resp["name"] = Json(ca.name);
      resp["description"] = Json(ca.description);
      resp["businessName"] = Json(ca.businessName);
      resp["sourceObjectId"] = Json(ca.sourceObjectId);
      resp["owner"] = Json(ca.owner);
      resp["glossaryTerms"] = stringsToJsonArray(ca.glossaryTerms);
      resp["accessCount"] = Json(ca.accessCount);
      resp["createdAt"] = Json(ca.createdAt);
      resp["updatedAt"] = Json(ca.updatedAt);
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

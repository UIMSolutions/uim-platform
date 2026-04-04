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

class CatalogAssetController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.businessName = jsonStr(j, "businessName");
      r.assetType = jsonStr(j, "assetType");
      r.sourceObjectId = jsonStr(j, "sourceObjectId");
      r.owner = jsonStr(j, "owner");
      r.glossaryTerms = jsonStrArray(j, "glossaryTerms");

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
      foreach (ref ca; assets) {
        auto aj = Json.emptyObject;
        aj["id"] = Json(ca.id);
        aj["name"] = Json(ca.name);
        aj["description"] = Json(ca.description);
        aj["businessName"] = Json(ca.businessName);
        aj["owner"] = Json(ca.owner);
        aj["accessCount"] = Json(ca.accessCount);
        aj["createdAt"] = Json(ca.createdAt);
        jarr ~= aj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) assets.length);
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
      foreach (ref ca; assets) {
        auto aj = Json.emptyObject;
        aj["id"] = Json(ca.id);
        aj["name"] = Json(ca.name);
        aj["description"] = Json(ca.description);
        aj["businessName"] = Json(ca.businessName);
        aj["owner"] = Json(ca.owner);
        jarr ~= aj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) assets.length);
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

      auto ca = uc.get_(id, spaceId);
      if (ca.id.length == 0) {
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
      resp["glossaryTerms"] = toJsonArray(ca.glossaryTerms);
      resp["accessCount"] = Json(ca.accessCount);
      resp["createdAt"] = Json(ca.createdAt);
      resp["modifiedAt"] = Json(ca.modifiedAt);
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

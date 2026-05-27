/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.spatial_feature;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class SpatialFeatureController : ManageController {
  private ManageSpatialFeaturesUseCase usecase;

  this(ManageSpatialFeaturesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/spatial/features", &handleList);
    router.get("/api/v1/spatial/features/*", &handleGet);
    router.post("/api/v1/spatial/features", &handleCreate);
    router.put("/api/v1/spatial/features/*", &handleUpdate);
    router.delete_("/api/v1/spatial/features/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateSpatialFeatureRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.layerId = j.getString("layerId");
      r.name = j.getString("name");
      r.geometryType = j.getString("geometryType");
      r.geometry = j.getString("geometry");
      r.properties = j.getString("properties");
      r.tags = jsonKeyValuePairs(j, "tags");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Spatial feature created"), 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto layerId = req.query.get("layerId", "");
      SpatialFeature[] items;
      if (layerId.length > 0) {
        items = usecase.listByLayer(tenantId, layerId);
      } else {
        items = usecase.list(tenantId);
      }

      auto jarr = Json.emptyArray;
      foreach (item; items) {
        jarr ~= Json.emptyObject
          .set("id", item.id.value)
          .set("layerId", item.layerId.value)
          .set("name", item.name)
          .set("geometryType", item.geometryType.to!string)
          .set("createdAt", item.createdAt);
      }

      res.writeJsonBody(Json.emptyObject.set("count", Json(items.length)).set("resources", jarr), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto item = usecase.getById(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "Spatial feature not found");
        return;
      }
      res.writeJsonBody(item.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto j = req.json;
      UpdateSpatialFeatureRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = j.getString("name");
      r.geometry = j.getString("geometry");
      r.properties = j.getString("properties");
      r.tags = jsonKeyValuePairs(j, "tags");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Spatial feature updated"), 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto result = usecase.remove(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.spatial_layer;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class SpatialLayerController : ManageHttpController {
  private ManageSpatialLayersUseCase usecase;

  this(ManageSpatialLayersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/spatial/layers", &handleList);
    router.get("/api/v1/spatial/layers/*", &handleGet);
    router.post("/api/v1/spatial/layers", &handleCreate);
    router.put("/api/v1/spatial/layers/*", &handleUpdate);
    router.delete_("/api/v1/spatial/layers/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
              CreateSpatialLayerRequest r;
      r.tenantId = tenantId;
      r.id = SpatialLayerId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.coordinateSystem = data.getString("coordinateSystem");
      r.isPublic = data.getBoolean("isPublic");
      r.metadata = jsonKeyValuePairs(j, "metadata");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        
        return successResponse("Spatial layer created successfully", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto items = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (item; items) {
        jarr ~= Json.emptyObject
          .set("id", item.id.value)
          .set("name", item.name)
          .set("type", item.type.to!string)
          .set("coordinateSystem", item.coordinateSystem)
          .set("featureCount", item.featureCount)
          .set("isPublic", item.isPublic)
          .set("createdAt", item.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", items.length)
        .set("resources", jarr);
        return successResponse("Spatial layers retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = SpatialLayerId(precheck.id);
      auto item = usecase.getById(tenantId, id);
      if (item.isNull)
            return errorResponse("", 0);
            
     return successResponse("Spatial layer retrieved successfully", "Retrieved", 200, item.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateSpatialLayerRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.isPublic = data.getBoolean("isPublic");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        
        return successResponse("Spatial layer updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = SpatialLayerId(precheck.id);
      if (id.isNull)
            return errorResponse("Invalid spatial layer ID", 400);
            
      auto result = usecase.remove(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        return successResponse("Spatial layer deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
  }
}

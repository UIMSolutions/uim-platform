/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.master_data;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage.master_data_objects;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class MasterDataController : PlatformController {
  private ManageMasterDataObjectsUseCase uc;

  this(ManageMasterDataObjectsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/master-data", &handleCreate);
    router.get("/api/v1/master-data", &handleList);
    router.get("/api/v1/master-data/lookup", &handleLookupByGlobalId);
    router.get("/api/v1/master-data/*", &handleGetById);
    router.put("/api/v1/master-data/*", &handleUpdate);
    router.delete_("/api/v1/master-data/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateMasterDataObjectRequest r;
      r.tenantId = req.getTenantId;
      r.dataModelId = j.getString("dataModelId");
      r.category = j.getString("category");
      r.objectType = j.getString("objectType");
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.localId = j.getString("localId");
      r.globalId = j.getString("globalId");
      r.attributes = jsonStrMap(j, "attributes");
      r.sourceSystem = j.getString("sourceSystem");
      r.sourceClient = j.getString("sourceClient");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto category = req.params.get("category", "");

      MasterDataObject[] objs;
      if (category.length > 0)
        objs = uc.listByCategory(tenantId, category);
      else
        objs = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (o; objs)
        arr ~= serializeObj(o);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(objs.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleLookupByGlobalId(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto globalId = req.params.get("globalId", "");
      if (globalid.isEmpty) {
        writeError(res, 400, "globalId query parameter is required");
        return;
      }

      auto obj = uc.findByGlobalId(tenantId, globalId);
      if (obj.id.isEmpty) {
        writeError(res, 404, "Master data object not found");
        return;
      }
      res.writeJsonBody(serializeObj(obj), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto obj = uc.getObject(id);
      if (obj.id.isEmpty) {
        writeError(res, 404, "Master data object not found");
        return;
      }
      res.writeJsonBody(serializeObj(obj), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateMasterDataObjectRequest r;
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.attributes = jsonStrMap(j, "attributes");
      r.modifiedBy = req.headers.get("X-User-Id", "");

      auto result = uc.updateObject(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteObject(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeObj(MasterDataObject o) {
    return Json.emptyObject
      .set("id", Json(o.id))
      .set("tenantId", Json(o.tenantId))
      .set("dataModelId", Json(o.dataModelId))
      .set("category", Json(o.category.to!string))
      .set("status", Json(o.status.to!string))
      .set("objectType", Json(o.objectType))
      .set("displayName", Json(o.displayName))
      .set("description", Json(o.description))
      .set("currentVersion", Json(o.currentVersion))
      .set("versionNumber", Json(o.versionNumber))
      .set("localId", Json(o.localId))
      .set("globalId", Json(o.globalId))
      .set("attributes", serializeStrMap(o.attributes))
      .set("sourceSystem", Json(o.sourceSystem))
      .set("sourceClient", Json(o.sourceClient))
      .set("createdBy", Json(o.createdBy))
      .set("createdAt", Json(o.createdAt))
      .set("modifiedAt", Json(o.modifiedAt))
      .set("modifiedBy", Json(o.modifiedBy));
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.master_data;






// import uim.platform.master_data_integration.application.usecases.manage.master_data_objects;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.master_data_object;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class MasterDataController : ManageController {
  private ManageMasterDataObjectsUseCase usecase;

  this(ManageMasterDataObjectsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/master-data", &handleCreate);
    router.get("/api/v1/master-data", &handleList);
    router.get("/api/v1/master-data/lookup", &handleLookupByGlobalId);
    router.get("/api/v1/master-data/*", &handleGet);
    router.put("/api/v1/master-data/*", &handleUpdate);
    router.delete_("/api/v1/master-data/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateMasterDataObjectRequest r;
      r.tenantId = tenantId;
      r.dataModelId = data.getString("dataModelId");
      r.category = data.getString("category");
      r.objectType = data.getString("objectType");
      r.displayName = data.getString("displayName");
      r.description = data.getString("description");
      r.localId = data.getString("localId");
      r.globalId = data.getString("globalId");
      r.attributes = data.jsonStrMap("attributes");
      r.sourceSystem = data.getString("sourceSystem");
      r.sourceClient = data.getString("sourceClient");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Master data object created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto category = req.params.get("category", "");

      MasterDataObject[] objs;
      if (category.length > 0)
        objs = usecase.listByCategory(tenantId, category);
      else
        objs = usecase.listByTenant(tenantId);

      auto arr = objs.map!(o => o.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", objs.length)
        .set("message", "Master data objects retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleLookupByGlobalId(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto globalId = req.params.get("globalId", "");
      if (globalId.isEmpty) {
        writeError(res, 400, "globalId query parameter is required");
        return;
      }

      auto obj = usecase.findByGlobalId(tenantId, globalId);
      if (obj.isNull) {
        writeError(res, 404, "Master data object not found");
        return;
      }
      res.writeJsonBody(obj.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto obj = usecase.getObject(id);
      if (obj.isNull) {
        writeError(res, 404, "Master data object not found");
        return;
      }
      res.writeJsonBody(obj.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateMasterDataObjectRequest r;
      r.displayName = data.getString("displayName");
      r.description = data.getString("description");
      r.status = data.getString("status");
      r.attributes = data.jsonStrMap("attributes");
      r.updatedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.updateObject(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteObject(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
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
      .set("updatedAt", Json(o.updatedAt))
      .set("updatedBy", Json(o.updatedBy));
  }
}

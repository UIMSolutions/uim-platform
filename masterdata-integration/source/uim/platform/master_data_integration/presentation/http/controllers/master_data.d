/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.master_data;

// import uim.platform.master_data_integration.application.usecases.manage.master_data_objects;

// import uim.platform.master_data_integration.domain.entities.master_data_object;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
class MasterDataController : ManageHttpController {
  private ManageMasterDataObjectsUseCase usecase;

  this(ManageMasterDataObjectsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/master-data", &handleCreate);
    router.get("/api/v1/master-data", &handleList);
    router.get("/api/v1/master-data/lookup", &handleLookupByGlobal);
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
    CreateMasterDataObjectRequest r;
    r.tenantId = tenantId;
    r.modelId = data.getString("dataModelId");
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

    auto result = usecase.createObject(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Master data object created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto category = req.params.get("category", "");

    MasterDataObject[] objs = category.length > 0 
      ? usecase.listObjects(tenantId, category) 
      : usecase.listObjects(tenantId);
    
    auto arr = objs.map!(o => o.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", objs.length);
    return successResponse("Master data objects retrieved successfully", 200, resp);
  }

  protected Json lookupByGlobalHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto globalId = req.params.get("globalId", "");
    if (globalId.isEmpty)
      return errorResponse("globalId query parameter is required", 400);

    auto obj = usecase.findObject(tenantId, globalId);
    if (obj.isNull)
      return errorResponse("Master data object not found", 404);

    auto response = obj.toJson();
    return successResponse("Master data object retrieved successfully", 200, response);
  }

  protected void handleLookupByGlobal(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = lookupByGlobalHandler(req);
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
    auto id = MasterDataObjectId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid master data object ID", 400);

    auto obj = usecase.getObject(tenantId, id);
    if (obj.isNull)
      return errorResponse("Master data object not found", 404);

    auto response = obj.toJson();
    return successResponse("Master data object retrieved successfully", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MasterDataObjectId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid master data object ID", 400);

    auto data = precheck.data;
    UpdateMasterDataObjectRequest r;
    r.tenantId = tenantId;
    r.objectId = id;
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.status = data.getString("status");
    r.attributes = data.jsonStrMap("attributes");
    r.updatedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.updateObject(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Master data object updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MasterDataObjectId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid master data object ID", 400);

    auto result = usecase.deleteObject(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Master data object deleted successfully", "Deleted", 200, responseData);
  }
}

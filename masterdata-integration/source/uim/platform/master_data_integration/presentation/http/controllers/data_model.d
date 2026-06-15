/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.data_model;

// import uim.platform.master_data_integration.application.usecases.manage.data_models;

// import uim.platform.master_data_integration.domain.entities.data_model;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
class DataModelController : ManageHttpController {
  private ManageDataModelsUseCase usecase;

  this(ManageDataModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-models", &handleCreate);
    router.get("/api/v1/data-models", &handleList);
    router.get("/api/v1/data-models/*", &handleGet);
    router.put("/api/v1/data-models/*", &handleUpdate);
    router.delete_("/api/v1/data-models/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataModelRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.namespace = data.getString("namespace");
    r.version_ = data.getString("version");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.keyFields = data.getStrings("keyFields");
    r.requiredFields = data.getStrings("requiredFields");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    // Parse field definitions
    FieldDefinitionDto[] fields;
    foreach (fdata; data.getArray("fields")) {
      FieldDefinitionDto fd;
      fd.name = fdata.getString("name");
      fd.displayName = fdata.getString("displayName");
      fd.type_ = fdata.getString("type");
      fd.isRequired = fdata.getBoolean("isRequired");
      fd.isKey = fdata.getBoolean("isKey");
      fd.defaultValue = fdata.getString("defaultValue");
      fd.maxLength = jsonInt(fdata, "maxLength");
      fd.referenceModel = fdata.getString("referenceModel");
      fd.description = fdata.getString("description");
      fields ~= fd;
    }
    r.fields = fields;

    auto result = usecase.createModel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Data model created successfully", 201, result);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto category = req.params.get("category", "");

    DataModel[] models = category.length > 0
      ? usecase.listModelsByCategory(tenantId, category) : usecase.listModelsByTenant(tenantId);

    auto arr = models.map!(m => m.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", models.length);

    return successResponse("Data models retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data model ID", 400);

    auto model = usecase.getModel(tenantId, id);
    if (model.isNull)
      return errorResponse("Data model not found", 404);

    auto responseData = model.toJson();
    return successResponse("Data model retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data model ID", 400);

    auto data = precheck.data;
    UpdateDataModelRequest r;
    r.tenantId = tenantId;
    r.modelId = id;
    r.description = data.getString("description");
    r.version_ = data.getString("version");
    r.keyFields = data.getStrings("keyFields");
    r.requiredFields = data.getStrings("requiredFields");

    FieldDefinitionDto[] fields;
    foreach (fdata; data.getArray("fields")) {
      FieldDefinitionDto fd;
      fd.name = fdata.getString("name");
      fd.displayName = fdata.getString("displayName");
      fd.type_ = fdata.getString("type");
      fd.isRequired = fdata.getBoolean("isRequired");
      fd.isKey = fdata.getBoolean("isKey");
      fd.defaultValue = fdata.getString("defaultValue");
      fd.maxLength = jsonInt(fdata, "maxLength");
      fd.referenceModel = fdata.getString("referenceModel");
      fd.description = fdata.getString("description");
      fields ~= fd;
    }
    r.fields = fields;

    auto result = usecase.updateModel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Data model updated successfully", 200, result);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data model ID", 400);

    auto result = usecase.deleteModel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Data model deleted successfully", 200, result);
  }
}

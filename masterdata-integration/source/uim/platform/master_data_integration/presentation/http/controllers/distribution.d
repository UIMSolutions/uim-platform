/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.distribution_model;

// import uim.platform.master_data_integration.application.usecases.manage.distribution_models;

// import uim.platform.master_data_integration.domain.entities.distribution_model;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class DistributionController : ManageHttpController {
  private ManageDistributionModelsUseCase usecase;

  this(ManageDistributionModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/distribution-models", &handleCreate);
    router.get("/api/v1/distribution-models", &handleList);
    router.get("/api/v1/distribution-models/*", &handleGet);
    router.put("/api/v1/distribution-models/*", &handleUpdate);
    router.delete_("/api/v1/distribution-models/*", &handleDelete);
    router.post("/api/v1/distribution-models/activate/*", &handleActivate);
    router.post("/api/v1/distribution-models/deactivate/*", &handleDeactivate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDistributionModelRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.direction = data.getString("direction");
    r.sourceClientId = data.getString("sourceClientId");
    r.targetClientIds = data.getStrings("targetClientIds").map!(id => ClientId(id)).array;
    r.categories = data.getStrings("categories");
    r.dataModelIds = data.getStrings("dataModelIds").map!(id => DataModelId(id)).array;
    r.filterRuleIds = data.getStrings("filterRuleIds").map!(id => FilterRuleId(id)).array;
    r.autoReplicate = data.getBoolean("autoReplicate");
    r.cronSchedule = data.getString("cronSchedule");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createModel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Distribution model created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto status = req.params.get("status", "");

    DistributionModel[] models = status.length > 0
      ? usecase.listModels(tenantId, status)
      : usecase.listModels(tenantId);

    auto arr = models.map!(m => m.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", models.length);

    return successResponse("Distribution models retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DistributionModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid distribution model ID", 400);

    auto model = usecase.getModel(tenantId, id);
    if (model.isNull)
      return errorResponse("Distribution model not found", 404);

    auto responseData = model.toJson();
    return successResponse("Distribution model retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DistributionModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid distribution model ID", 400);

    auto data = precheck.data;
    UpdateDistributionModelRequest r;
    r.tenantId = tenantId;
    r.modelId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.status = data.getString("status");
    r.targetClientIds = data.getStrings("targetClientIds").map!(id => ClientId(id)).array;
    r.categories = data.getStrings("categories");
    r.dataModelIds = data.getStrings("dataModelIds").map!(id => DataModelId(id)).array;
    r.filterRuleIds = data.getStrings("filterRuleIds").map!(id => FilterRuleId(id)).array;
    r.autoReplicate = data.getBoolean("autoReplicate");
    r.cronSchedule = data.getString("cronSchedule");

    auto result = usecase.updateModel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Distribution model updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DistributionModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid distribution model ID", 400);

    auto result = usecase.deleteModel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Distribution model deleted successfully", "Deleted", 204, resp);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DistributionModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid distribution model ID", 400);

    auto result = usecase.activateModel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Distribution model activated successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleActivate", "activateHandler"));

  protected Json deactivateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DistributionModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid distribution model ID", 400);

    auto result = usecase.deactivateModel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Distribution model deactivated successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleDeactivate", "deactivateHandler"));

}

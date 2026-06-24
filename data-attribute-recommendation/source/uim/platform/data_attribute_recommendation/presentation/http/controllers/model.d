/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers.model;

// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.models;

// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;

import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());
@safe:
class ModelController : ManageHttpController {
  private ManageModelsUseCase usecase;

  this(ManageModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/models", &handleCreate);
    router.get("/api/v1/models", &handleList);
    router.get("/api/v1/models/*", &handleGet);
    router.put("/api/v1/models/*", &handleUpdate);
    router.delete_("/api/v1/models/*", &handleDelete);
    router.post("/api/v1/models/activate/*", &handleActivate);
    router.post("/api/v1/models/train/*", &handleTrain);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateModelConfigRequest();
    r.tenantId = tenantId;
    r.datasetId = data.getString("datasetId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.modelType = data.getString("modelType");
    r.targetColumns = data.getString("targetColumns");
    r.featureColumns = data.getString("featureColumns");
    r.hyperparameters = data.getString("hyperparameters");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createModelConfig(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Model configuration created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listModelConfigs(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Model configuration list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ModelConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model configuration ID", 400);
    auto config = usecase.getModelConfig(tenantId, id);
    if (config.isNull)
      return errorResponse("Model configuration not found", 404);

    auto responseData = config.toJson();
    return successResponse("Model configuration retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ModelConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model configuration ID", 400);

    auto data = precheck.data;
    auto r = UpdateModelConfigRequest();
    r.configId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.modelType = data.getString("modelType");
    r.targetColumns = data.getString("targetColumns");
    r.featureColumns = data.getString("featureColumns");
    r.hyperparameters = data.getString("hyperparameters");

    auto result = usecase.updateModelConfig(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Model configuration updated successfully", 200, responseData);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ModelConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model configuration ID", 400);

    auto result = usecase.activateConfig(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Model configuration activated successfully", 200, responseData);
  }

  mixin(HandleTemplate!("handleActivate", "activateHandler"));

  protected Json trainHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ModelConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model configuration ID", 400);

    auto r = StartTrainingRequest();
    r.configId = id;
    r.tenantId = tenantId;
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.startTraining(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("jobId", result.id);
    return successResponse("Model training started successfully", "Running", 202, responseData);
  }

  mixin(HandleTemplate!("handleTrain", "trainHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ModelConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model configuration ID", 400);

    auto result = usecase.deleteModelConfig(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Model configuration deleted successfully", "Deleted", 200, responseData);
  }
}

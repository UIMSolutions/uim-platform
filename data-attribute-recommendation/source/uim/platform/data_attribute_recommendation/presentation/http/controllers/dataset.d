/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers.dataset;

// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.datasets;



import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());
@safe:
class DatasetController : ManageHttpController {
  private ManageDatasetsUseCase usecase;

  this(ManageDatasetsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/datasets", &handleCreate);
    router.get("/api/v1/datasets", &handleList);
    router.get("/api/v1/datasets/*", &handleGet);
    router.put("/api/v1/datasets/*", &handleUpdate);
    router.delete_("/api/v1/datasets/*", &handleDelete);
    router.post("/api/v1/datasets/validate/*", &handleValidate);
    router.post("/api/v1/datasets/process/*", &handleProcess);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateDatasetRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.dataType = parseDataType(data.getString("dataType"));
    r.columnDefinitions = data.getString("columnDefinitions");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createDataset(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listDatasets(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Datasets retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);

    auto item = usecase.getDataset(tenantId, id);
    if (item.isNull)
      return errorResponse("Dataset not found", 404);

    auto responseData = item.toJson();
    return successResponse("Dataset retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);
      
    auto data = precheck.data;
    auto r = UpdateDatasetRequest();
    r.tenantId = tenantId;
    r.datasetId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.columnDefinitions = data.getString("columnDefinitions");

    auto result = usecase.updateDataset(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset updated successfully", "Updated", 200, responseData);
  }

  protected Json validateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);

    auto result = usecase.validateDataset(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset validation completed successfully", "Validated", 200, responseData);
  }

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = validateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json processHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);

    auto result = usecase.processDataset(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset processing started successfully", "Processing", 200, responseData);
  }

  protected void handleProcess(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = processHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);

    auto result = usecase.deleteDataset(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset deleted successfully", "Deleted", 200, responseData);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.dataset;

// import uim.platform.ai_launchpad.application.usecases.manage.datasets;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class DatasetController : ManageController {
  private ManageDatasetsUseCase usecase;

  this(ManageDatasetsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/datasets", &handleRegister);
    router.get("/api/v1/datasets", &handleList);
    router.get("/api/v1/datasets/*", &handleGet);
    router.patch("/api/v1/datasets/*", &handlePatch);
    router.delete_("/api/v1/datasets/*", &handleDelete);
  }

  protected Json registerHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    RegisterDatasetRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.scenarioId = data.getString("scenarioId");
    r.url = data.getString("url");
    r.size = jsonLong(data, "size");
    r.labels = data.getStrings("labels");

    auto result = usecase.registerDataset(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset registered successfully", 201, responseData);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = registerHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

    auto datasets = scenarioId.isEmpty
      ? usecase.listDatasets(tenantId, connectionId) : usecase.listDatasets(tenantId, connectionId, scenarioId);

    auto list = datasets.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Dataset list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto dataset = usecase.getDataset(tenantId, connectionId, id);
    if (dataset.isNull)
      return errorResponse("Dataset not found", 404);

    auto responseData = dataset.toJson();
    return successResponse("Dataset retrieved successfully", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);

    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    PatchDatasetRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.datasetId = id;
    r.description = data.getString("description");
    r.status = data.getString("status");

    auto result = usecase.patchDataset(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("message", "Dataset updated successfully");

    return successResponse("Dataset updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DatasetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dataset ID", 400);
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto result = usecase.deleteDataset(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Dataset deleted successfully", 200, responseData);
  }
}

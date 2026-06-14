/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.training_job;
// import uim.platform.document_ai.application.usecases.manage.training_jobs;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.training_job : TrainingJob;

import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:

class TrainingJobController : ManageHttpController {
  private ManageTrainingJobsUseCase usecase;

  this(ManageTrainingJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/training/jobs", &handleCreate);
    router.get("/api/v1/training/jobs", &handleList);
    router.get("/api/v1/training/jobs/*", &handleGet);
    router.patch("/api/v1/training/jobs/*", &handlePatch);
    router.delete_("/api/v1/training/jobs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;

    CreateTrainingJobRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.documentTypeId = data.getString("documentTypeId");
    r.schemaId = data.getString("schemaId");
    r.name = data.getString("name");
    r.description = data.getString("description");

    auto result = usecase.createTrainingJob(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Training job created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
    auto jobs = usecase.listTrainingJobs(tenantId, clientId);

    auto list = jobs.map!(tj => jobToJson(tj)).array.toJson;

    auto resp = Json.emptyObject
      .set("count", jobs.length)
      .set("resources", list);

    return successResponse("Training job list retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TrainingJobId(precheck.id);
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto tj = usecase.getTrainingJob(tenantId, id, clientId);
    if (tj.isNull)
      return errorResponse("Training job not found", 404);

    return successResponse("Training job retrieved successfully", 200, jobToJson(tj));
  }

  protected Json handlePatch(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TrainingJobId(precheck.id);
    auto data = precheck.data;
    PatchTrainingJobRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.trainingJobId = id;
    r.targetStatus = data.getString("targetStatus");

    auto result = usecase.patchTrainingJob(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Training job updated successfully", 200, resp);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJson(response, response.code);
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
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto result = usecase.deleteTrainingJob(tenantId, id, clientId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Training job deleted successfully", 200, responseData);
  }
}

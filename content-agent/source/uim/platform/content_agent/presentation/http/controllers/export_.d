/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.export_;

// import uim.platform.content_agent.application.usecases.export_content;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.export_job;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class ExportController : PlatformController {
  private ExportContentUseCase usecase;

  this(ExportContentUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/exports", &handleStartExport);
    router.get("/api/v1/exports", &handleList);
    router.get("/api/v1/exports/*", &handleGet);
  }

  protected Json startExportHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = StartExportRequest();
    r.tenantId = tenantId;
    r.packageId = data.getString("packageId");
    r.transportRequestId = data.getString("transportRequestId");
    r.queueId = data.getString("queueId");
    r.startedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.startExport(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Export started successfully", "Created", 201, responseData);
  }

  protected void handleStartExport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = startExportHandler(req);
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

    auto jobs = usecase.listExportJobs(tenantId);
    auto list = jobs.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Export jobs retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ExportJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid export job ID", 400);

    auto job = usecase.getExportJob(tenantId, id);
    if (job.isNull)
      return errorResponse("Export job not found", 404);

    auto responseData = job.toJson();
    return successResponse("Export job retrieved successfully", "Retrieved", 200, responseData);
  }
}

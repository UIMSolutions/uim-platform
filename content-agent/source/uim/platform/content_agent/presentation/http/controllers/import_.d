/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.import_;

// import uim.platform.content_agent.application.usecases.import_content;

// import uim.platform.content_agent.domain.entities.import_job;

import uim.platform.content_agent;
mixin(ShowModule!());

@safe:
class ImportController : ManageHttpController {
  private ImportContentUseCase usecase;

  this(ImportContentUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/imports", &handleStartImport);
    router.get("/api/v1/imports", &handleList);
    router.get("/api/v1/imports/*", &handleGet);
  }

  protected Json startImportHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = StartImportRequest();
    r.tenantId = tenantId;
    r.packageId = ContentPackageId(data.getString("packageId"));
    r.transportRequestId = TransportRequestId(data.getString("transportRequestId"));
    r.sourceFilePath = data.getString("sourceFilePath");
    r.startedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.startImport(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", "completed");

    return successResponse("Import started successfully", "Started", 201, resp);
  }

  mixin(HandleTemplate!("handleStartImport", "startImportHandler"));

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto jobs = usecase.listImportJobs(tenantId);
    auto list = jobs.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Import jobs retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ImportJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid import job ID", 400);

    auto job = usecase.getImportJob(tenantId, id);
    if (job.isNull)
      return errorResponse("Import job not found", 404);

    return successResponse("Import job retrieved successfully", "Retrieved", 200, job.toJson());
  }
}

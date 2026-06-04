/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.export_;
// 
// 
// import uim.platform.auditlog.application.usecases.manage.exports;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class ExportController : ManageHttpController {
  private ManageExportsUseCase useCase;

  this(ManageExportsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/exports", &handleCreate);
    router.get("/api/v1/exports", &handleList);
    router.get("/api/v1/exports/*", &handleGet);
    router.delete_("/api/v1/exports/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto jobs = useCase.listExports(tenantId);
    auto list = jobs.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Export job list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateExportJobRequest jobRequest = CreateExportJobRequest();
    jobRequest.tenantId = precheck.tenantId;
    jobRequest.requestedBy = data.getString("requestedBy");
    jobRequest.timeFrom = jsonLong(data, "timeFrom");
    jobRequest.timeTo = jsonLong(data, "timeTo");

    auto fmtStr = data.getString("format");
    jobRequest.format_ = fmtStr == "csv"
      ? ExportFormat.csv : ExportFormat.json;

    // Parse category filter
    auto cats = data.getStrings("categories");
    foreach (c; cats)
      jobRequest.categories ~= toAuditCategory(c);

    auto result = useCase.createExport(jobRequest);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Export job created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ExportJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid export job ID", 400);

    auto item = useCase.getExport(tenantId, id);
    if (item.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = item.toJson();
    return successResponse("Export job retrieved successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ExportJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid export job ID", 400);

    auto result = useCase.deleteExport(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Export job deleted successfully", 200, responseData);
  }
}

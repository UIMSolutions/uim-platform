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
class ExportController : ManageController {
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

  override protected Json listHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;

    auto jobs = useCase.listExports(tenantId);
    auto arr = jobs.map!(j => j.toJson).array.toJson;

    return Json.emptyObject
      .set("status", 200)
      .set("items", arr)
      .set("totalCount", Json(jobs.length))
      .set("message", "Export jobs retrieved successfully");
  }

  override protected Json createHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto j = req.json;

    CreateExportJobRequest jobRequest = CreateExportJobRequest();
    jobRequest.tenantId = tenantId;
    jobRequest.requestedBy = j.getString("requestedBy");
    jobRequest.timeFrom = jsonLong(j, "timeFrom");
    jobRequest.timeTo = jsonLong(j, "timeTo");

    auto fmtStr = j.getString("format");
    jobRequest.format_ = fmtStr == "csv"
       ? ExportFormat.csv
       : ExportFormat.json;

    // Parse category filter
    auto cats = getStrings(j, "categories");
    foreach (c; cats)
      jobRequest.categories ~= toAuditCategory(c);

    auto result = useCase.createExport(jobRequest);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("error", result.error)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("message", "Export job created successfully");

  }

  override protected Json getHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    ExportJobId jobId = ExportJobId(extractIdFromPath(req.requestURI));
    auto tenantId = req.getTenantId;

    auto job = useCase.getExport(tenantId, jobId);
    if (job.isNull) {
      return Json.emptyObject
        .set("error", "Export job not found")
        .set("statusCode", 404);
    }
    return job.toJson
      .set("statusCode", 200)
      .set("message", "Export job retrieved successfully");
  }

  override protected Json deleteHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    ExportJobId jobId = ExportJobId(extractIdFromPath(req.requestURI));
    auto tenantId = req.getTenantId;

    auto result = useCase.deleteExport(tenantId, jobId);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("error", result.error)
        .set("statusCode", 400);
    }
    return Json.emptyObject
      .set("status", "deleted")
      .set("statusCode", 200)
      .set("message", "Export job deleted successfully");
  }
}

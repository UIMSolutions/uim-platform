/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.export_controller;




// import uim.platform.content_agent.application.usecases.export_content;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.export_job;
// import uim.platform.content_agent.domain.types;
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

  protected void handleStartExport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      auto r = StartExportRequest();
      r.tenantId = tenantId;
      r.packageId = j.getString("packageId");
      r.transportRequestId = j.getString("transportRequestId");
      r.queueId = j.getString("queueId");
      r.startedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.startExport(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed")
          .set("message", "Export started successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto jobs = usecase.listExportJobs(tenantId);

      auto arr = jobs.map!(j => j.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(jobs.length))
        .set("message", "Export jobs retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto job = usecase.getExportJob(id);
      if (job.isNull) {
        writeError(res, 404, "Export job not found");
        return;
      }
      auto resp = job.toJson
        .set("message", "Export job retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeExportJob(const ExportJob job) {
    return Json.emptyObject
      .set("id", job.id)
      .set("tenantId", job.tenantId)
      .set("packageId", job.packageId)
      .set("transportRequestId", job.transportRequestId)
      .set("queueId", job.queueId)
      .set("status", job.status.to!string)
      .set("exportedFilePath", job.exportedFilePath)
      .set("exportedSizeBytes", job.exportedSizeBytes)
      .set("createdBy", job.createdBy)
      .set("startedAt", job.startedAt)
      .set("completedAt", job.completedAt)
      .set("errorMessage", job.errorMessage);
  }
}

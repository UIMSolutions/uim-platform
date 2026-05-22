/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.import_controller;

// import uim.platform.content_agent.application.usecases.import_content;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.import_job;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class ImportController : PlatformController {
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

  protected void handleStartImport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = StartImportRequest();
      r.tenantId = tenantId;
      r.packageId = ContentPackageId(j.getString("packageId"));
      r.transportRequestId = TransportRequestId(j.getString("transportRequestId"));
      r.sourceFilePath = j.getString("sourceFilePath");
      r.startedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.startImport(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed")
          .set("message", "Import started successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto jobs = usecase.listImportJobs(tenantId);

      auto arr = jobs.map!(j => j.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(jobs.length))
        .set("message", "Import jobs retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ImportJobId(extractIdFromPath(req.requestURI));
      auto job = usecase.getImportJob(tenantId, id);
      if (job.isNull) {
        writeError(res, 404, "Import job not found");
        return;
      }
      res.writeJsonBody(job.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

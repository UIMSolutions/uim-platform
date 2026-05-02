/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.import_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.content_agent.application.usecases.import_content;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.import_job;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class ImportController : PlatformController {
  private ImportContentUseCase uc;

  this(ImportContentUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/imports", &handleStartImport);
    router.get("/api/v1/imports", &handleList);
    router.get("/api/v1/imports/*", &handleGetById);
  }

  private void handleStartImport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = StartImportRequest();
      r.tenantId = req.getTenantId;
      r.packageId = j.getString("packageId");
      r.transportRequestId = j.getString("transportRequestId");
      r.sourceFilePath = j.getString("sourceFilePath");
      r.startedBy = req.headers.get("X-User-Id", "");

      auto result = uc.startImport(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed")
          .set("message", "Import started successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto jobs = uc.listImportJobs(tenantId);

      auto arr = jobs.map!(j => j.toJson).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(jobs.length))
        .set("message", "Import jobs retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto job = uc.getImportJob(id);
      if (job.isNull) {
        writeError(res, 404, "Import job not found");
        return;
      }
      res.writeJsonBody(job.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeImportJob(const ImportJob imp) {
    return Json.emptyObject
      .set("id", imp.id)
      .set("tenantId", imp.tenantId)
      .set("packageId", imp.packageId)
      .set("transportRequestId", imp.transportRequestId)
      .set("sourceFilePath", imp.sourceFilePath)
      .set("status", imp.status.to!string)
      .set("importedSizeBytes", imp.importedSizeBytes)
      .set("createdBy", imp.createdBy)
      .set("startedAt", imp.startedAt)
      .set("completedAt", imp.completedAt)
      .set("errorMessage", imp.errorMessage)
      .set("deployedItems", imp.deployedItems);
  }
}

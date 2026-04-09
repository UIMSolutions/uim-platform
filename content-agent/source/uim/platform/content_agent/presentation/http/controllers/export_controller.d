/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.export_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.content_agent.application.usecases.export_content;
import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.export_job;
import uim.platform.content_agent.domain.types;

class ExportController : PlatformController {
  private ExportContentUseCase uc;

  this(ExportContentUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/exports", &handleStartExport);
    router.get("/api/v1/exports", &handleList);
    router.get("/api/v1/exports/*", &handleGetById);
  }

  private void handleStartExport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = StartExportRequest();
      r.tenantId = req.getTenantId;
      r.packageId = j.getString("packageId");
      r.transportRequestId = j.getString("transportRequestId");
      r.queueId = j.getString("queueId");
      r.startedBy = req.headers.get("X-User-Id", "");

      auto result = uc.startExport(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("completed");
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto jobs = uc.listExportJobs(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref j; jobs)
        arr ~= serializeExportJob(j);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) jobs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto job = uc.getExportJob(id);
      if (job.id.isEmpty) {
        writeError(res, 404, "Export job not found");
        return;
      }
      res.writeJsonBody(serializeExportJob(job), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeExportJob(ref const ExportJob e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["packageId"] = Json(e.packageId);
    j["transportRequestId"] = Json(e.transportRequestId);
    j["queueId"] = Json(e.queueId);
    j["status"] = Json(e.status.to!string);
    j["exportedFilePath"] = Json(e.exportedFilePath);
    j["exportedSizeBytes"] = Json(e.exportedSizeBytes);
    j["createdBy"] = Json(e.createdBy);
    j["startedAt"] = Json(e.startedAt);
    j["completedAt"] = Json(e.completedAt);
    j["errorMessage"] = Json(e.errorMessage);
    return j;
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.export_;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.auditlog.application.usecases.manage.exports;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class ExportController : SAPController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateExportJobRequest jobRequest = CreateExportJobRequest();
      jobRequest.tenantId = req.getTenantId;
      jobRequest.requestedBy = j.getString("requestedBy");
      jobRequest.timeFrom = jsonLong(j, "timeFrom");
      jobRequest.timeTo = jsonLong(j, "timeTo");

      auto fmtStr = j.getString("format");
      if (fmtStr == "csv")
        jobRequest.format_ = ExportFormat.csv;
      else
        jobRequest.format_ = ExportFormat.json;

      // Parse category filter
      auto cats = jsonStrArray(j, "categories");
      foreach (c; cats)
        jobRequest.categories ~= parseCategory(c);

      auto result = useCase.createExport(jobRequest);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
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
      auto jobs = useCase.listExports(tenantId);
      auto arr = jobs.map!(j => serializeJob(j)).array.toJson;
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(cast(long)jobs.length));
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ExportJobId jobId = ExportJobId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      if (!useCase.hasExport(tenantId, jobId)) {
        writeError(res, 404, "Export job not found");
        return;
      }

      auto job = useCase.getExport(tenantId, jobId);
      res.writeJsonBody(serializeJob(job), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ExportJobId jobId = ExportJobId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      useCase.deleteExport(tenantId, jobId);
      auto resp = Json.emptyObject
        .set("status", "deleted");
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJob(ref const ExportJob exportJob) {
    auto json = Json.emptyObject
      .set("id", exportJob.id)
      .set("tenantId", exportJob.tenantId)
      .set("requestedBy", exportJob.requestedBy)
      .set("format", exportJob.format_.to!string)
      .set("status", exportJob.status.to!string)
      .set("totalRecords", exportJob.totalRecords)
      .set("downloadUrl", exportJob.downloadUrl)
      .set("timeFrom", exportJob.timeFrom)
      .set("timeTo", exportJob.timeTo)
      .set("createdAt", exportJob.createdAt)
      .set("completedAt", exportJob.completedAt)
      .set("errorMessage", exportJob.errorMessage);

    if (exportJob.categories.length > 0) {
      auto cats = exportJob.categories.map!(c => Json(categoryToString(c))).array.toJson;
      json["categories"] = cats;
    }
    return json;
  }

  private static AuditCategory parseCategory(string s) {
    switch (s) {
    case "audit.security-events", "securityEvents":
      return AuditCategory.securityEvents;
    case "audit.configuration", "configuration":
      return AuditCategory.configuration;
    case "audit.data-access", "dataAccess":
      return AuditCategory.dataAccess;
    case "audit.data-modification", "dataModification":
      return AuditCategory.dataModification;
    default:
      return AuditCategory.securityEvents;
    }
  }

  private static string categoryToString(AuditCategory c) {
    final switch (c) {
    case AuditCategory.securityEvents:
      return "audit.security-events";
    case AuditCategory.configuration:
      return "audit.configuration";
    case AuditCategory.dataAccess:
      return "audit.data-access";
    case AuditCategory.dataModification:
      return "audit.data-modification";
    }
  }
}

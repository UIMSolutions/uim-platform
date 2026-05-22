/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.information_report;
// import uim.platform.data.privacy.application.usecases.manage.information_reports;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.information_report;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class InformationReportController : PlatformController {
  private ManageInformationReportsUseCase usecase;

  this(ManageInformationReportsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/information-reports", &handleCreate);
    router.get("/api/v1/information-reports", &handleList);
    router.get("/api/v1/information-reports/*", &handleGet);
    router.put("/api/v1/information-reports/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/information-reports/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateInformationReportRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
      r.requestedBy = UserId(j.getString("requestedBy"));
      r.format = j.getString("format");
      r.targetSystems = getStrings(j, "targetSystems");
      r.categories = getStrings(j, "categories").map!(s => s.to!PersonalDataCategory).array;
      r.reason = j.getString("reason");

      auto result = usecase.createReport(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Information report created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto items = usecase.listReports(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Information reports retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = InformationReportId(extractIdFromPath(req.requestURI));

      auto entry = usecase.getReport(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Information report not found");
        return;
      }
      auto resp = entry.toJson
        .set("message", "Information report retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateInformationReportStatusRequest r;
      r.id = InformationReportId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.status = parseReportStatus(j.getString("status"));
      r.downloadUrl = j.getString("downloadUrl");
      r.totalRecords = jsonLong(j, "totalRecords");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(response, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = InformationReportId(extractIdFromPath(req.requestURI));
      
      usecase.deleteReport(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const InformationReport e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("subjectRole", e.subjectRole)
      .set("requestedBy", e.requestedBy)
      .set("status", e.status.to!string)
      .set("format", e.format.to!string)
      .set("downloadUrl", e.downloadUrl)
      .set("totalRecords", e.totalRecords)
      .set("reason", e.reason)
      .set("requestedAt", e.requestedAt)
      .set("generatedAt", e.generatedAt)
      .set("expiresAt", e.expiresAt);
  }

  private static InformationReportStatus parseReportStatus(string status) {
    switch (status) {
    case "generating":
      return InformationReportStatus.generating;
    case "completed":
      return InformationReportStatus.completed;
    case "failed":
      return InformationReportStatus.failed;
    default:
      return InformationReportStatus.requested;
    }
  }
}

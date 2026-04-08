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
class InformationReportController : SAPController {
  private ManageInformationReportsUseCase uc;

  this(ManageInformationReportsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/information-reports", &handleCreate);
    router.get("/api/v1/information-reports", &handleList);
    router.get("/api/v1/information-reports/*", &handleGetById);
    router.put("/api/v1/information-reports/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/information-reports/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateInformationReportRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.format = j.getString("format");
      r.targetSystems = jsonStrArray(j, "targetSystems");
      r.categories = jsonStrArray(j, "categories");
      r.reason = j.getString("reason");

      auto result = uc.createReport(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listReports(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getReport(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Information report not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateInformationReportStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.status = parseReportStatus(j.getString("status"));
      r.downloadUrl = j.getString("downloadUrl");
      r.totalRecords = jsonLong(j, "totalRecords");

      auto result = uc.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteReport(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const InformationReport e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["dataSubjectId"] = Json(e.dataSubjectId);
    j["subjectRole"] = Json(e.subjectRole);
    j["requestedBy"] = Json(e.requestedBy);
    j["status"] = Json(e.status.to!string);
    j["format"] = Json(e.format.to!string);
    j["downloadUrl"] = Json(e.downloadUrl);
    j["totalRecords"] = Json(e.totalRecords);
    j["reason"] = Json(e.reason);
    j["requestedAt"] = Json(e.requestedAt);
    j["generatedAt"] = Json(e.generatedAt);
    j["expiresAt"] = Json(e.expiresAt);
    return j;
  }

  private static InformationReportStatus parseReportStatus(string s) {
    switch (s) {
      case "generating": return InformationReportStatus.generating;
      case "completed": return InformationReportStatus.completed;
      case "failed": return InformationReportStatus.failed;
      default: return InformationReportStatus.requested;
    }
  }
}

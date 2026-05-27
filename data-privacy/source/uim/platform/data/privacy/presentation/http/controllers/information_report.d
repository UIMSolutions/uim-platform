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
class InformationReportController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      CreateInformationReportRequest r;
      r.tenantId = tenantId;
      r.subjectId = DataSubjectId(j.getString("dataSubjectId"));
      r.requestedBy = UserId(j.getString("requestedBy"));
      r.format = j.getString("format");
      r.targetSystems = getStrings(j, "targetSystems");
      r.categories = getStrings(j, "categories");
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

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = InformationReportId(precheck.id);

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

  override protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      UpdateInformationReportStatusRequest r;
      r.reportId = InformationReportId(precheck.id);
      r.tenantId = tenantId;
      r.status = j.getString("status");
      r.downloadUrl = j.getString("downloadUrl");
      r.totalRecords = j.getLong("totalRecords");

      auto result = usecase.updateReportStatus(r);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(response, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = InformationReportId(precheck.id);

      usecase.deleteReport(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

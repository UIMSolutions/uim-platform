/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.information_report;
// import uim.platform.data.privacy.application.usecases.manage.information_reports;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.information_report;
import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
class InformationReportController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateInformationReportRequest r;
    r.tenantId = tenantId;
    r.subjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.requestedBy = UserId(data.getString("requestedBy"));
    r.format = data.getString("format");
    r.targetSystems = data.getStrings("targetSystems");
    r.categories = data.getStrings("categories");
    r.reason = data.getString("reason");

    auto result = usecase.createReport(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Information report created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listReports(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Information reports retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = InformationReportId(precheck.id);

    auto entry = usecase.getReport(tenantId, id);
    if (entry.isNull)
      return errorResponse("Information report not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Information report retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = InformationReportId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid information report ID", 400);

    auto data = precheck.data;
    UpdateInformationReportStatusRequest r;
    r.reportId = id;
    r.tenantId = tenantId;
    r.status = data.getString("status");
    r.downloadUrl = data.getString("downloadUrl");
    r.totalRecords = data.getLong("totalRecords");

    auto result = usecase.updateReportStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Information report status updated successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleUpdateStatus", "updateStatusHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = InformationReportId(precheck.id);

    auto result = usecase.deleteReport(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Information report deleted successfully", "Deleted", 200, responseData);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_retrieval_request;






// import uim.platform.data.privacy.application.usecases.manage.data_retrievals;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_retrieval_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DataRetrievalController : PlatformController {
  private ManageDataRetrievalsUseCase usecase;

  this(ManageDataRetrievalsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-retrievals", &handleCreate);
    router.get("/api/v1/data-retrievals", &handleList);
    router.get("/api/v1/data-retrievals/*", &handleGet);
    router.put("/api/v1/data-retrievals/*", &handleUpdateStatus);
    router.delete_("/api/v1/data-retrievals/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDataRetrievalRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = getStrings(j, "targetSystems");
      r.reason = j.getString("reason");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data retrieval request created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto statusParam = req.headers.get("X-Status-Filter", "");
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      DataRetrievalRequest[] items = statusParam.length > 0
        ? usecase.listByStatus(tenantId, parseRetrievalStatus(statusParam))
        : usecase.listRequests(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataRetrievalRequestId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Data retrieval request not found");
        return;
      } 
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateRetrievalStatusRequest r;
      r.id = DataRetrievalRequestId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.status = parseRetrievalStatus(j.getString("status"));
      r.downloadUrl = j.getString("downloadUrl");
      r.totalFields = jsonLong(j, "totalFields");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data retrieval request status updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataRetrievalRequestId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const DataRetrievalRequest e) {
    auto systems = Json.emptyArray;
    foreach (s; e.targetSystems)
      systems ~= Json(s);

    auto cats = e.categories.map!(c => Json(c.to!string)).array.toJson;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("requestedBy", e.requestedBy)
      .set("requestType", e.requestType.to!string)
      .set("status", e.status.to!string)
      .set("downloadUrl", e.downloadUrl)
      .set("totalFields", e.totalFields)
      .set("reason", e.reason)
      .set("requestedAt", e.requestedAt)
      .set("completedAt", e.completedAt)
      .set("deadline", e.deadline)
      .set("targetSystems", systems)
      .set("categories", cats);
  }

  private static RetrievalStatus parseRetrievalStatus(string status) {
    switch (status) {
    case "inProgress":
      return RetrievalStatus.inProgress;
    case "completed":
      return RetrievalStatus.completed;
    case "failed":
      return RetrievalStatus.failed;
    default:
      return RetrievalStatus.requested;
    }
  }
}

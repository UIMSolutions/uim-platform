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
class DataRetrievalController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateDataRetrievalRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
      r.requestedBy = data.getString("requestedBy");
      r.targetSystems = data.getStrings("targetSystems");
      r.reason = data.getString("reason");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data retrieval request created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto statusParam = req.headers.get("X-Status-Filter", "");
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      DataRetrievalRequest[] items = statusParam.length > 0
        ? usecase.listByStatus(tenantId, toRetrievalStatus(statusParam))
        : usecase.listRequests(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = DataRetrievalRequestId(precheck.id);

      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Data retrieval request not found");
        return;
      } 
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      UpdateRetrievalStatusRequest r;
      r.id = DataRetrievalRequestId(precheck.id);
      r.tenantId = tenantId;
      r.status = data.getString("status");
      r.downloadUrl = data.getString("downloadUrl");
      r.totalFields = jsonLong(j, "totalFields");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data retrieval request status updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = DataRetrievalRequestId(precheck.id);

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
}

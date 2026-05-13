/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.transport_request;






// import uim.platform.abap_environment.application.usecases.manage.transport_requests;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.transport_request;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
class TransportRequestController : PlatformController {
  private ManageTransportRequestsUseCase usecase;

  this(ManageTransportRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/transports", &handleCreate);
    router.get("/api/v1/transports", &handleList);
    router.get("/api/v1/transports/*", &handleGet);
    router.post("/api/v1/transports/tasks/*", &handleAddTask);
    router.post("/api/v1/transports/release/*", &handleRelease);
    router.post("/api/v1/transports/release-task/*", &handleReleaseTask);
    router.delete_("/api/v1/transports/*", &handleDelete);
  }

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateTransportRequestRequest r;
      r.tenantId = tenantId;
      r.sourceSystemId = j.getString("sourceSystemId");
      r.targetSystemId = j.getString("targetSystemId");
      r.description = j.getString("description");
      r.owner = j.getString("owner");
      r.transportType = j.getString("transportType");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Transport request created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
      auto requests = usecase.listRequests(tenantId, systemId);
      auto arr = requests.map!(tr => tr.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", requests.length)
        .set("message", "Transport requests retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = TransportRequestId(extractIdFromPath(req.requestURI));
      auto tr = usecase.getRequest(tenantId, id);
      if (tr.isNull) {
        writeError(res, 404, "Transport request not found");
        return;
      }
      res.writeJsonBody(tr.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetAddTask(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto requestId = TransportRequestId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      AddTransportTaskRequest r;
      r.tenantId = tenantId;
      r.owner = j.getString("owner");
      r.description = j.getString("description");
      r.objectList = getStrings(j, "objectList");

      auto result = usecase.addTask(requestId, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("taskId", result.id)
          .set("message", "Transport task added");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = TransportRequestId(extractIdFromPath(req.requestURI));

      auto result = usecase.releaseRequest(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "released")
          .set("message", "Transport request released");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetReleaseTask(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto requestId = TransportRequestId(j.getString("requestId"));
      auto taskId = TransportTaskId(extractIdFromPath(req.requestURI));

      auto result = usecase.releaseTask(tenantId, requestId, taskId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "released")
          .set("message", "Transport task released");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = TransportRequestId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.deleteRequest(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Transport request deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}

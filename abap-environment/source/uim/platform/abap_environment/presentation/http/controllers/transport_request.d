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
class TransportRequestController : ManageController {
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

  protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

    auto requests = usecase.listTransportRequests(tenantId, systemId);
    auto arr = requests.map!(tr => tr.toJson).array.toJson;

    return successResponse("Transport requests retrieved", "Retrieved", 200,
      Json.emptyObject
        .set("items", arr)
        .set("totalCount", requests.length));
  }

  protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateTransportRequestRequest r;
    r.tenantId = tenantId;
    r.sourceSystemId = data.getString("sourceSystemId");
    r.targetSystemId = data.getString("targetSystemId");
    r.description = data.getString("description");
    r.owner = data.getString("owner");
    r.transportType = data.getString("transportType");

    auto result = usecase.createTransportRequest(r);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Transport request created", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TransportRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid transport request id", 400);

    auto tr = usecase.getTransportRequest(tenantId, id);
    if (tr.isNull)
      return errorResponse("Transport request not found", 404);

    return successResponse("Transport request retrieved", "Retrieved", 200, tr.toJson);
  }

  protected Json addTaskHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto requestId = TransportRequestId(precheck.id);
    if (requestId.isNull)
      return errorResponse("Invalid transport request id", 400);

    auto data = precheck.data;

    AddTransportTaskRequest r;
    r.transportRequestId = requestId;
    r.tenantId = tenantId;
    r.owner = data.getString("owner");
    r.description = data.getString("description");
    r.objectList = getStrings(data, "objectList");

    auto result = usecase.addTransportTask(r);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Transport task added", "Added", 201,
      Json.emptyObject.set("taskId", result.id));
  }

  protected void handleAddTask(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = addTaskHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json releaseHandler(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto id = TransportRequestId(extractIdFromPath(req.requestURI));
    auto result = usecase.releaseTransportRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Transport request released", "Released", 200);
  }

  protected void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = releaseHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json releaseTaskHandler(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto j = req.json;
    auto requestId = TransportRequestId(j.getString("requestId"));
    if (requestId.isNull)
      return errorResponse("Invalid transport request id", 400);

    auto taskId = TransportTaskId(extractIdFromPath(req.requestURI));
    if (taskId.isNull)
      return errorResponse("Invalid transport task id", 400);

    auto result = usecase.releaseTransportTask(tenantId, requestId, taskId);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Transport task released", "Released", 200);
  }

  protected void handleReleaseTask(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = releaseTaskHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TransportRequestId(precheck.id);

    auto result = usecase.deleteTransportRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Transport request deleted", "Deleted", 200,
      Json.emptyObject.set("id", result.id));
  }
}

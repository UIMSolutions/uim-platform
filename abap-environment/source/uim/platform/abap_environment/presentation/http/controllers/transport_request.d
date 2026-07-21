/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.transport_request;

// import uim.platform.abap_environment.application.usecases.manage.transport_requests;

// import uim.platform.abap_environment.domain.entities.transport_request;


import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
class TransportRequestController : ManageHttpController {
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

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

    auto requests = usecase.listTransportRequests(tenantId, systemId);
    auto arr = requests.map!(tr => tr.toJson).array.toJson;

    return successResponse("Transport requests retrieved", "Retrieved", 200,
      Json.emptyObject
        .set("items", arr)
        .set("totalCount", requests.length));
  }

  override protected Json createHandler(HTTPServerRequest req) {
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
    r.requestId = requestId;
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

  mixin(HandleTemplate!("handleAddTask", "addTaskHandler"));

  protected Json releaseHandler(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TransportRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid transport request id", 400);

    auto result = usecase.releaseTransportRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Transport request released", "Released", 200, resp);
  }

  mixin(HandleTemplate!("handleRelease", "releaseHandler"));

  protected Json releaseTaskHandler(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto requestId = TransportRequestId(data.getString("requestId"));
    if (requestId.isNull)
      return errorResponse("Invalid transport request id", 400);

    auto taskId = TransportTaskId(precheck.id);
    if (taskId.isNull)
      return errorResponse("Invalid transport task id", 400);

    auto result = usecase.releaseTransportTask(tenantId, requestId, taskId);
    if (result.hasError)
      return errorResponse(result.message);

    auto resp = Json.emptyObject.set("id", requestId.value).set("taskId", taskId.value);
    return successResponse("Transport task released", "Released", 200, resp);
  }

  mixin(HandleTemplate!("handleReleaseTask", "releaseTaskHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
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

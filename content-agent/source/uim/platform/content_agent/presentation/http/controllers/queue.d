/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.queue;

// import uim.platform.content_agent.application.usecases.manage.transport_queues;

// import uim.platform.content_agent.domain.entities.transport_queue;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
class QueueController : ManageHttpController {
  private ManageTransportQueuesUseCase usecase;

  this(ManageTransportQueuesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/queues", &handleCreate);
    router.get("/api/v1/queues", &handleList);
    router.get("/api/v1/queues/*", &handleGet);
    router.put("/api/v1/queues/*", &handleUpdate);
    router.delete_("/api/v1/queues/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateQueueRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.queueType = data.getString("queueType");
    r.endpoint = data.getString("endpoint");
    r.authToken = data.getString("authToken");
    r.isDefault = data.getBoolean("isDefault");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createQueue(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Queue created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto queues = usecase.listQueues(tenantId);
    auto list = queues.map!(q => q.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Queue list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = QueueId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid queue ID", 400);

    auto queue = usecase.getQueue(tenantId, id);
    if (queue.isNull)
      return errorResponse("Queue not found", 404);

    auto responseData = queue.toJson();
    return successResponse("Queue retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = QueueId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid queue ID", 400);

    auto data = precheck.data;
    auto r = UpdateQueueRequest();
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.endpoint = data.getString("endpoint");
    r.authToken = data.getString("authToken");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.updateQueue(id, r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Queue updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = QueueId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid queue ID", 400);

    auto result = usecase.deleteQueue(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Queue deleted successfully", 200, responseData);
  }
}

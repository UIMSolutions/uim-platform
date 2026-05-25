/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.topic;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class TopicController : ManageController {
  private ManageTopicsUseCase usecase;

  this(ManageTopicsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/event-mesh/topics", &handleList);
    router.get("/api/v1/event-mesh/topics/*", &handleGet);
    router.post("/api/v1/event-mesh/topics", &handleCreate);
    router.put("/api/v1/event-mesh/topics/*", &handleUpdate);
    router.delete_("/api/v1/event-mesh/topics/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listTopics(tenantId);
    auto jarr = items.map!(e => e.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("count", items.length)
      .set("resources", jarr);

    return successResoponse("Topic list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    TopicDTO dto;
    dto.topicId = TopicId(data.getString("id"));
    dto.tenantId = tenantId;
    dto.serviceId = BrokerServiceId(data.getString("brokerServiceId"));
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.topicString = data.getString("topicString");
    dto.maxMessageSize = data.getString("maxMessageSize");
    dto.publishEnabled = data.getString("publishEnabled");
    dto.subscribeEnabled = data.getString("subscribeEnabled");
    dto.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createTopic(dto);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Topic created");

    return successResponse("Topic created successfully", "Created", 201, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = TopicId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid topic ID", 400);

    auto topic = usecase.getTopic(tenantId, (id));
    if (topic.isNull)
      return errorResponse("Topic not found", 404);

    return successResponse("Topic retrieved successfully", "Retrieved", 200, topic.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    TopicDTO dto;
    dto.topicId = TopicId(extractIdFromPath(path));
    dto.tenantId = tenantId;
    dto.name = j.getString("name");
    dto.description = j.getString("description");
    dto.topicString = j.getString("topicString");
    dto.maxMessageSize = j.getString("maxMessageSize");
    dto.updatedBy = UserId(j.getString("updatedBy"));

    auto result = usecase.updateTopic(dto);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Topic updated");

    return successResponse("Topic updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = TopicId(extractIdFromPath(path));
    auto result = usecase.deleteTopic(tenantId, id);
    if (result.success) {
      auto resp = Json.emptyObject
        .set("message", "Topic deleted");

      res.writeJsonBody(resp, 200);
    } else {
      writeError(res, 404, result.message);
    }
  }
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}
}

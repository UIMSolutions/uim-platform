/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.topic;

import std.uuid : randomUUID;

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
    auto list = items.map!(e => e.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);

    return successResponse("Topic list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto createId = precheck.id;
    if (createId.isEmpty) {
      try {
        createId = req.params["id"];
      } catch (Exception) {
      }
    }
    if (createId.isEmpty)
      createId = randomUUID().toString();

    TopicDTO dto;
    dto.topicId = TopicId(createId);
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
    dto.topicId = TopicId(precheck.id);
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.topicString = data.getString("topicString");
    dto.maxMessageSize = data.getString("maxMessageSize");
    dto.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.updateTopic(dto);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);

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
    auto id = TopicId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid topic ID", 400);
      
    auto result = usecase.deleteTopic(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("message", "Topic deleted");

    return successResponse("Topic deleted successfully", "Deleted", 200, resp);
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class TopicControllerTest : ControllerTestBase {
    void runTests() {
      // 1. Setup
      auto repo = new MemoryTopicRepository();
      auto usecase = new ManageTopicsUseCase(repo);
      auto controller = new TopicController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 2. Test List Handler
      auto reqList = createMockRequest("GET", "/api/v1/event-mesh/topics", tenantId);
      auto resList = controller.listHandler(reqList);
      assert(resList.getString("status") != "error");
      assert(resList["data"]["count"].get!int == 0);

      // 3. Test Create Handler
      Json createData = Json.emptyObject
        .set("brokerServiceId", "broker-1")
        .set("name", "Test Topic")
        .set("topicString", "test/topic")
        .set("createdBy", "user-1");

      auto reqCreate = createMockRequest("POST", "/api/v1/event-mesh/topics", tenantId, createData);
      reqCreate.params["id"] = "topic-1";
      auto resCreate = controller.createHandler(reqCreate);
      assert(resCreate.getString("status") != "error");
      assert(resCreate["data"]["id"].get!string == "topic-1");

      // 4. Test Get Handler
      auto reqGet = createMockRequest("GET", "/api/v1/event-mesh/topics/topic-1", tenantId);
      reqGet.params["id"] = "topic-1";
      auto resGet = controller.getHandler(reqGet);
      assert(resGet.getString("status") != "error");
      assert(resGet["data"]["name"].get!string == "Test Topic");

      // 5. Test Update Handler
      Json updateData = Json.emptyObject
        .set("name", "Updated Topic")
        .set("updatedBy", "user-2");
      auto reqUpdate = createMockRequest("PUT", "/api/v1/event-mesh/topics/topic-1", tenantId, updateData);
      reqUpdate.params["id"] = "topic-1";
      auto resUpdate = controller.updateHandler(reqUpdate);
      assert(resUpdate.getString("status") != "error");

      // Verify update
      auto resGet2 = controller.getHandler(reqGet);
      assert(resGet2["data"]["name"].get!string == "Updated Topic");

      // 6. Test Delete Handler
      auto reqDelete = createMockRequest("DELETE", "/api/v1/event-mesh/topics/topic-1", tenantId);
      reqDelete.params["id"] = "topic-1";
      auto resDelete = controller.deleteHandler(reqDelete);
      assert(resDelete.getString("status") != "error");

      // Verify deletion
      auto resGet3 = controller.getHandler(reqGet);
      assert(resGet3.getString("status") == "error"); // Expect 404
    }
  }

  auto runner = new TopicControllerTest();
  runner.runTests();
}

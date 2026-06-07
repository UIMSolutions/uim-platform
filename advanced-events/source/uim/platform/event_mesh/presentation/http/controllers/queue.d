/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.queue;

import std.uuid : randomUUID;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class QueueController : ManageHttpController {
    private ManageQueuesUseCase usecase;

    this(ManageQueuesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/queues", &handleList);
        router.get("/api/v1/event-mesh/queues/*", &handleGet);
        router.post("/api/v1/event-mesh/queues", &handleCreate);
        router.put("/api/v1/event-mesh/queues/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/queues/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listQueues(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Queue list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = QueueId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid queue ID", 400);
        auto queue = usecase.getQueue(tenantId, id);

        if (queue.isNull)
            return errorResponse("Queue not found", 404);

        auto responseData = queue.toJson();
        return successResponse("Queue retrieved successfully", "Retrieved", 200, responseData);
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

        QueueDTO dto;
        dto.queueId = QueueId(createId);
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("brokerServiceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.maxMsgSpoolUsage = data.getString("maxMsgSpoolUsage");
        dto.maxBindCount = data.getString("maxBindCount");
        dto.maxMsgSize = data.getString("maxMsgSize");
        dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
        dto.maxTtl = data.getString("maxTtl");
        dto.deadMessageQueue = data.getString("deadMessageQueue");
        dto.owner = data.getString("owner");
        dto.permission = data.getString("permission");
        dto.egressEnabled = data.getString("egressEnabled");
        dto.ingressEnabled = data.getString("ingressEnabled");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createQueue(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Queue created successfully", "Created", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        QueueDTO dto;
        dto.queueId = QueueId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.maxMsgSpoolUsage = data.getString("maxMsgSpoolUsage");
        dto.maxBindCount = data.getString("maxBindCount");
        dto.maxMsgSize = data.getString("maxMsgSize");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateQueue(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Queue updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = QueueId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid queue ID", 400);

        auto result = usecase.deleteQueue(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("message", "Queue deleted");

        return successResponse("Queue deleted successfully", "Deleted", 200, resp);
    }
}

unittest {
  import uim.platform.service.tests;

  @safe class QueueControllerTest : ControllerTestBase {
    void runTests() {
      // 1. Setup
      auto repo = new MemoryQueueRepository();
      auto usecase = new ManageQueuesUseCase(repo);
      auto controller = new QueueController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 2. Test List Handler
      auto reqList = createMockRequest("GET", "/api/v1/event-mesh/queues", tenantId);
      auto resList = controller.listHandler(reqList);
      assert(resList.getString("status") != "error");
      assert(resList["data"]["count"].get!int == 0);

      // 3. Test Create Handler
      Json createData = Json.emptyObject
        .set("brokerServiceId", "broker-1")
        .set("name", "Test Queue")
        .set("description", "A test queue")
        .set("createdBy", "user-1");

      auto reqCreate = createMockRequest("POST", "/api/v1/event-mesh/queues", tenantId, createData);
      reqCreate.params["id"] = "queue-1";
      auto resCreate = controller.createHandler(reqCreate);
      assert(resCreate.getString("status") != "error");
      assert(resCreate["data"]["id"].get!string == "queue-1");

      // 4. Test Get Handler
      auto reqGet = createMockRequest("GET", "/api/v1/event-mesh/queues/queue-1", tenantId);
      reqGet.params["id"] = "queue-1";
      auto resGet = controller.getHandler(reqGet);
      assert(resGet.getString("status") != "error");
      assert(resGet["data"]["name"].get!string == "Test Queue");

      // 5. Test Update Handler
      Json updateData = Json.emptyObject
        .set("name", "Updated Queue")
        .set("updatedBy", "user-2");
      auto reqUpdate = createMockRequest("PUT", "/api/v1/event-mesh/queues/queue-1", tenantId, updateData);
      reqUpdate.params["id"] = "queue-1";
      auto resUpdate = controller.updateHandler(reqUpdate);
      assert(resUpdate.getString("status") != "error");

      // Verify update
      auto resGet2 = controller.getHandler(reqGet);
      assert(resGet2["data"]["name"].get!string == "Updated Queue");

      // 6. Test Delete Handler
      auto reqDelete = createMockRequest("DELETE", "/api/v1/event-mesh/queues/queue-1", tenantId);
      reqDelete.params["id"] = "queue-1";
      auto resDelete = controller.deleteHandler(reqDelete);
      assert(resDelete.getString("status") != "error");

      // Verify deletion
      auto resGet3 = controller.getHandler(reqGet);
      assert(resGet3.getString("status") == "error"); // Expect 404
    }
  }

  auto runner = new QueueControllerTest();
  runner.runTests();
}

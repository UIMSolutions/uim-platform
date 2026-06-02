/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.subscription;

import std.uuid : randomUUID;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class SubscriptionController : ManageController {
    private ManageSubscriptionsUseCase usecase;

    this(ManageSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/subscriptions", &handleList);
        router.get("/api/v1/event-mesh/subscriptions/*", &handleGet);
        router.post("/api/v1/event-mesh/subscriptions", &handleCreate);
        router.put("/api/v1/event-mesh/subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/subscriptions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listSubscriptions(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Subscription list retrieved successfully", "Retrieved", 200, resp);
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

        SubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(createId);
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("serviceId"));
        dto.topicId = TopicId(data.getString("topicId"));
        dto.queueId = QueueId(data.getString("queueId"));
        dto.applicationId = EventApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicFilter = data.getString("topicFilter");
        dto.selector = data.getString("selector");
        dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
        dto.maxTtl = data.getString("maxTtl");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createSubscription(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Subscription created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        auto e = usecase.getSubscription(tenantId, id);
        if (e.isNull)
            return errorResponse("Subscription not found", 404);

        auto responseData = e.toJson();
        return successResponse("Subscription retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = EventSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        SubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicFilter = data.getString("topicFilter");
        dto.selector = data.getString("selector");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateSubscription(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Subscription updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = EventSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        auto result = usecase.deleteSubscription(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Subscription deleted successfully", "Deleted", 200, responseData);
    }
}

unittest {
    import uim.platform.service.tests;

    @safe class SubscriptionControllerTest : ControllerTestBase {
        void runTests() {
            // 1. Setup
            auto repo = new MemorySubscriptionRepository();
            auto usecase = new ManageSubscriptionsUseCase(repo);
            auto controller = new SubscriptionController(usecase);
            auto tenantId = TenantId("test-tenant");

            // 2. Test List Handler (Empty)
            auto reqList = createMockRequest("GET", "/api/v1/event-mesh/subscriptions", tenantId);
            auto resList = controller.listHandler(reqList);
            assert(resList.getString("status") != "error");
            assert(resList["data"]["count"].get!int == 0);

            // 3. Test Create Handler
            Json createData = Json.emptyObject
                .set("serviceId", "broker-1")
                .set("topicId", "topic-1")
                .set("name", "Test Subscription")
                .set("topicFilter", "test/topic/*")
                .set("createdBy", "user-1");

            auto reqCreate = createMockRequest("POST", "/api/v1/event-mesh/subscriptions", tenantId, createData);
            // Pre-checks usually extract the ID from the path or generate it if not provided.
            // For the mock, we simulate that the pre-check found 'sub-1'.
            reqCreate.params["id"] = "sub-1"; 
            
            auto resCreate = controller.createHandler(reqCreate);
            assert(resCreate.getString("status") != "error", resCreate.getString("message"));
            auto createdId = resCreate["data"]["id"].get!string;
            assert(createdId.length > 0);

            // 4. Test Get Handler
            auto reqGet = createMockRequest("GET", "/api/v1/event-mesh/subscriptions/" ~ createdId, tenantId);
            reqGet.params["id"] = createdId;
            auto resGet = controller.getHandler(reqGet);
            assert(resGet.getString("status") != "error");
            assert(resGet["data"]["name"].get!string == "Test Subscription");

            // 5. Test Update Handler
            Json updateData = Json.emptyObject
                .set("name", "Updated Subscription")
                .set("updatedBy", "user-2");
            auto reqUpdate = createMockRequest(
                "PUT",
                "/api/v1/event-mesh/subscriptions/" ~ createdId,
                tenantId,
                updateData);
            reqUpdate.params["id"] = createdId;
            auto resUpdate = controller.updateHandler(reqUpdate);
            assert(resUpdate.getString("status") != "error");

            // Verify update
            auto resGet2 = controller.getHandler(reqGet);
            assert(resGet2["data"]["name"].get!string == "Updated Subscription");

            // 6. Test Delete Handler
            auto reqDelete = createMockRequest("DELETE", "/api/v1/event-mesh/subscriptions/" ~ createdId, tenantId);
            reqDelete.params["id"] = createdId;
            auto resDelete = controller.deleteHandler(reqDelete);
            assert(resDelete.getString("status") != "error");

            // Verify deletion
            auto resGet3 = controller.getHandler(reqGet);
            assert(resGet3.getString("status") == "error"); // Should return a 404 response
        }
    }

    auto runner = new SubscriptionControllerTest();
    runner.runTests();
}
